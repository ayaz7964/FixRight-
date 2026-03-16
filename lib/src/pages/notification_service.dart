import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATION SERVICE
//  Writes to: notifications/{uid}/items/{notifId}
//  Each item: title, body, type, jobId, isRead, createdAt
// ═══════════════════════════════════════════════════════════════

class NotificationService {
  static final _db = FirebaseFirestore.instance;

  // ── Write a notification to a user ─────────────────────────
  static Future<void> send({
    required String toUid,
    required String title,
    required String body,
    required String type,   // bid_received | order_placed | claim_filed | payment_verified | expert_assigned | job_completed | earnings_released | bid_accepted | bid_rejected
    String? jobId,
    String? relatedUserName,
  }) async {
    if (toUid.isEmpty) return;
    try {
      await _db
          .collection('notifications')
          .doc(toUid)
          .collection('items')
          .add({
        'title': title,
        'body': body,
        'type': type,
        'jobId': jobId ?? '',
        'relatedUserName': relatedUserName ?? '',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService error: $e');
    }
  }

  // ── Mark all as read ────────────────────────────────────────
  static Future<void> markAllRead(String uid) async {
    final batch = _db.batch();
    final unread = await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();
    for (final d in unread.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Mark one as read ────────────────────────────────────────
  static Future<void> markRead(String uid, String notifId) async {
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notifId)
        .update({'isRead': true});
  }

  // ── Unread count stream ─────────────────────────────────────
  static Stream<int> unreadCount(String uid) {
    if (uid.isEmpty) return Stream.value(0);
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  // ── All notifications stream ────────────────────────────────
  static Stream<QuerySnapshot> allNotifications(String uid) {
    if (uid.isEmpty) return const Stream.empty();
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATION BELL WIDGET  — drop into any AppBar actions
//  Usage: NotificationBell(uid: _uid, onTap: () => Navigator.push(...))
// ═══════════════════════════════════════════════════════════════
class NotificationBell extends StatelessWidget {
  final String uid;
  final VoidCallback onTap;
  final Color color;
  const NotificationBell({
    super.key,
    required this.uid,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService.unreadCount(uid),
      builder: (context, snap) {
        final count = snap.data ?? 0;
        return IconButton(
          onPressed: onTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: color, size: 26),
              if (count > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  NOTIFICATIONS PAGE
// ═══════════════════════════════════════════════════════════════
class NotificationsPage extends StatelessWidget {
  final String uid;
  const NotificationsPage({super.key, required this.uid});

  IconData _iconForType(String type) {
    switch (type) {
      case 'bid_received':       return Icons.gavel;
      case 'order_placed':       return Icons.check_circle_outline;
      case 'claim_filed':        return Icons.policy;
      case 'payment_verified':   return Icons.verified;
      case 'expert_assigned':    return Icons.star;
      case 'job_completed':      return Icons.task_alt;
      case 'earnings_released':  return Icons.payments;
      case 'bid_accepted':       return Icons.celebration;
      case 'bid_rejected':       return Icons.cancel_outlined;
      default:                   return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'bid_received':       return Colors.orange;
      case 'order_placed':       return Colors.teal;
      case 'claim_filed':        return Colors.red;
      case 'payment_verified':   return Colors.green;
      case 'expert_assigned':    return Colors.purple;
      case 'job_completed':      return Colors.green;
      case 'earnings_released':  return Colors.green;
      case 'bid_accepted':       return Colors.green;
      case 'bid_rejected':       return Colors.red;
      default:                   return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => NotificationService.markAllRead(uid),
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.allNotifications(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('No notifications yet', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snap.data!.docs.length,
            itemBuilder: (ctx, i) {
              final doc = snap.data!.docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final type = data['type'] ?? '';
              final createdAt = data['createdAt'] as Timestamp?;
              final color = _colorForType(type);

              return GestureDetector(
                onTap: () => NotificationService.markRead(uid, doc.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isRead ? Colors.grey.shade200 : color.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle),
                      child: Icon(_iconForType(type), color: color, size: 22),
                    ),
                    title: Text(data['title'] ?? '',
                        style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['body'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        if (createdAt != null)
                          Text(_timeAgo(createdAt.toDate()),
                              style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    trailing: isRead
                        ? null
                        : Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}