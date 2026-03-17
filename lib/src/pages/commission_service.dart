// ═══════════════════════════════════════════════════════════════
//  COMMISSION SERVICE
//  Reads dynamic commission rate from Firestore config/commission
//  Firestore path: config/commission → { rate: 0.10, updatedAt: ... }
//  Also handles bid reservation logic to prevent negative balances
// ═══════════════════════════════════════════════════════════════
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionService {
  CommissionService._();
  static final CommissionService instance = CommissionService._();

  static const double _defaultRate = 0.10;
  static const int _freeOrderLimit = 3;
  static const double _minBalance = 500.0;

  // ── Fetch current commission rate from Firestore ──────────
  Future<double> getRate() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('commission')
          .get();
      if (doc.exists) {
        final rate = (doc.data()?['rate'] ?? _defaultRate).toDouble();
        return rate.clamp(0.0, 1.0);
      }
    } catch (_) {}
    return _defaultRate;
  }

  // ── Real-time stream of commission rate ───────────────────
  Stream<double> rateStream() {
    return FirebaseFirestore.instance
        .collection('config')
        .doc('commission')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return _defaultRate;
      return ((doc.data()?['rate'] ?? _defaultRate) as num)
          .toDouble()
          .clamp(0.0, 1.0);
    });
  }

  // ── Check if seller can place a bid ──────────────────────
  // Returns a BidEligibility object explaining why/why not
  Future<BidEligibility> checkBidEligibility({
    required String sellerUid,
    required double bidAmount,
  }) async {
    final sellerDoc = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .get();
    final data = sellerDoc.data() ?? {};
    final jobsCompleted = (data['Jobs_Completed'] ?? 0) as int;
    final availableBalance = (data['Available_Balance'] ?? 0).toDouble();
    // Reserved_Commission = sum of commissions held for all pending bids
    final reservedCommission = (data['Reserved_Commission'] ?? 0).toDouble();
    final isFree = jobsCompleted < _freeOrderLimit;
    final freeLeft = isFree ? _freeOrderLimit - jobsCompleted : 0;

    if (isFree) {
      return BidEligibility(
        canBid: true, isFree: true, freeLeft: freeLeft,
        commissionRequired: 0, availableBalance: availableBalance,
        reservedCommission: reservedCommission, rate: 0,
      );
    }

    final rate = await getRate();
    final commissionRequired = bidAmount * rate;
    // Free balance = what's actually usable (not already reserved)
    final freeBalance = availableBalance - reservedCommission;

    if (freeBalance < commissionRequired) {
      return BidEligibility(
        canBid: false, isFree: false, freeLeft: 0,
        commissionRequired: commissionRequired,
        availableBalance: availableBalance,
        reservedCommission: reservedCommission,
        freeBalance: freeBalance,
        rate: rate,
        reason: freeBalance < 0
            ? 'No available balance — previous bids have reserved PKR ${reservedCommission.toStringAsFixed(0)}'
            : 'Need PKR ${commissionRequired.toStringAsFixed(0)} for commission. Free balance: PKR ${freeBalance.toStringAsFixed(0)}',
      );
    }

    return BidEligibility(
      canBid: true, isFree: false, freeLeft: 0,
      commissionRequired: commissionRequired,
      availableBalance: availableBalance,
      reservedCommission: reservedCommission,
      freeBalance: freeBalance,
      rate: rate,
    );
  }

  // ── Reserve commission when bid is placed ─────────────────
  // Called atomically inside the bid placement batch
  Future<void> reserveCommission({
    required String sellerUid,
    required double commissionAmount,
  }) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .update({
      'Reserved_Commission': FieldValue.increment(commissionAmount),
    });
  }

  // ── Release reservation when bid is rejected or cancelled ─
  Future<void> releaseCommissionReservation({
    required String sellerUid,
    required double commissionAmount,
  }) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .update({
      'Reserved_Commission': FieldValue.increment(-commissionAmount),
    });
  }

  // ── Finalize commission when order is placed ──────────────
  // Deducts from Available_Balance AND releases the reservation
  // Called when buyer places order (accepts bid)
  Future<void> finalizeCommission({
    required String sellerUid,
    required double commissionAmount,
  }) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerUid)
        .update({
      'Available_Balance': FieldValue.increment(-commissionAmount),
      'Reserved_Commission': FieldValue.increment(-commissionAmount),
    });
  }

  // ── Release all reservations for rejected bids on a job ──
  // Called when buyer places order — reject other bidders and release their reserves
  static Future<void> releaseRejectedBidsReservations({
    required String jobId,
    required String acceptedSellerId,
    required List<QueryDocumentSnapshot> otherBids,
    required double rate,
    required bool isFree,
  }) async {
    if (isFree) return; // no reservations for free orders
    for (final bidDoc in otherBids) {
      final bidData = bidDoc.data() as Map<String, dynamic>;
      final rejectedSellerId = bidData['sellerId'] as String? ?? '';
      final bidAmount = (bidData['proposedAmount'] ?? 0).toDouble();
      final commission = bidAmount * rate;
      if (rejectedSellerId.isNotEmpty && commission > 0) {
        // Release reservation for rejected seller
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(rejectedSellerId)
            .update({'Reserved_Commission': FieldValue.increment(-commission)});
      }
    }
  }
}

// ── Eligibility result object ─────────────────────────────────
class BidEligibility {
  final bool canBid;
  final bool isFree;
  final int freeLeft;
  final double commissionRequired;
  final double availableBalance;
  final double reservedCommission;
  final double freeBalance;
  final double rate;
  final String? reason;

  BidEligibility({
    required this.canBid,
    required this.isFree,
    required this.freeLeft,
    required this.commissionRequired,
    required this.availableBalance,
    required this.reservedCommission,
    this.freeBalance = 0,
    required this.rate,
    this.reason,
  });

  String get ratePercent => '${(rate * 100).toStringAsFixed(0)}%';
  String get reservedFormatted => 'PKR ${reservedCommission.toStringAsFixed(0)}';
  String get commissionFormatted => 'PKR ${commissionRequired.toStringAsFixed(0)}';
  String get freeBalanceFormatted => 'PKR ${freeBalance.toStringAsFixed(0)}';
}