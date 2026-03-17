import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

// ═══════════════════════════════════════════════════════════════
//  RATING & FEEDBACK WIDGET
//  Shown to buyer after job is completed
//  Saves to: jobs/{jobId}/rating + sellers/{sellerUid}/ratings/{jobId}
//  Also updates sellers/{sellerUid}.Rating (running average)
// ═══════════════════════════════════════════════════════════════

class RatingFeedbackSection extends StatefulWidget {
  final String jobId;
  final String sellerUid;
  final String sellerName;
  final Map<String, dynamic> jobData;

  const RatingFeedbackSection({
    super.key,
    required this.jobId,
    required this.sellerUid,
    required this.sellerName,
    required this.jobData,
  });

  @override
  State<RatingFeedbackSection> createState() => _RatingFeedbackSectionState();
}

class _RatingFeedbackSectionState extends State<RatingFeedbackSection> {
  int _stars = 0;
  final int _hoveredStar = 0;
  final _commentCtrl = TextEditingController();
  bool _submitted = false;
  bool _loading = false;

  // Check if already rated
  bool get _alreadyRated => widget.jobData['ratingGiven'] == true;

  @override
  void initState() {
    super.initState();
    if (_alreadyRated) {
      _stars = (widget.jobData['buyerRating'] ?? 0) as int;
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final db = FirebaseFirestore.instance;
      final comment = _commentCtrl.text.trim();

      // 1. Save on the job document
      await db.collection('jobs').doc(widget.jobId).update({
        'buyerRating': _stars,
        'buyerFeedback': comment,
        'ratingGiven': true,
        'ratedAt': FieldValue.serverTimestamp(),
      });

      // 2. Save to seller's ratings subcollection
      await db
          .collection('sellers')
          .doc(widget.sellerUid)
          .collection('ratings')
          .doc(widget.jobId)
          .set({
        'jobId': widget.jobId,
        'jobTitle': widget.jobData['title'] ?? '',
        'stars': _stars,
        'comment': comment,
        'buyerUid': widget.jobData['postedBy'] ?? '',
        'buyerName': widget.jobData['posterName'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Recalculate seller's average rating
      final ratingsSnap = await db
          .collection('sellers')
          .doc(widget.sellerUid)
          .collection('ratings')
          .get();
      final allStars = ratingsSnap.docs
          .map((d) => (d.data()['stars'] ?? 0) as int)
          .toList();
      final avgRating = allStars.isEmpty
          ? _stars.toDouble()
          : allStars.reduce((a, b) => a + b) / allStars.length;

      await db.collection('sellers').doc(widget.sellerUid).update({
        'Rating': double.parse(avgRating.toStringAsFixed(1)),
      });

      // 4. Notify seller
      await NotificationService.send(
        toUid: widget.sellerUid,
        title: '⭐ New Rating Received',
        body: 'You received $_stars star${_stars > 1 ? 's' : ''} for "${widget.jobData['title'] ?? 'your job'}". ${comment.isNotEmpty ? '"$comment"' : ''}',
        type: 'job_completed',
        jobId: widget.jobId,
      );

      if (mounted) setState(() { _submitted = true; _loading = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        setState(() => _loading = false);
      }
    }
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent!';
      default: return 'Tap to rate';
    }
  }

  Color _starColor(int stars) {
    if (stars <= 1) return Colors.red;
    if (stars == 2) return Colors.orange;
    if (stars == 3) return Colors.amber;
    if (stars == 4) return Colors.lightGreen;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    // Already rated — show summary
    if (_alreadyRated || _submitted) {
      final existingStars = _submitted ? _stars : (widget.jobData['buyerRating'] ?? 0) as int;
      final existingComment = _submitted
          ? _commentCtrl.text.trim()
          : (widget.jobData['buyerFeedback'] ?? '') as String;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.verified, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 10),
          Row(children: List.generate(5, (i) => Icon(
            i < existingStars ? Icons.star : Icons.star_border,
            color: Colors.amber, size: 28,
          ))),
          const SizedBox(height: 6),
          Text(_starLabel(existingStars), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _starColor(existingStars))),
          if (existingComment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
              child: Text('"$existingComment"', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic)),
            ),
          ],
        ]),
      );
    }

    // Rate now
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.star_rate, color: Colors.orange.shade700, size: 22),
          const SizedBox(width: 8),
          Text('Rate ${widget.sellerName}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 15)),
        ]),
        const SizedBox(height: 8),
        Text('How was the service? Your feedback helps others choose the right worker.', style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
        const SizedBox(height: 14),

        // Star row
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              final starNum = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _stars = starNum),
                onPanUpdate: (d) {
                  // swipe to select stars
                  final w = (MediaQuery.of(context).size.width - 64) / 5;
                  final idx = (d.localPosition.dx / w).ceil().clamp(1, 5);
                  setState(() => _stars = idx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    starNum <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: starNum <= _stars ? 44 : 36,
                    color: starNum <= _stars ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        Center(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _starLabel(_stars),
            key: ValueKey(_stars),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _stars > 0 ? _starColor(_stars) : Colors.grey),
          ),
        )),
        const SizedBox(height: 12),

        // Comment
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your experience (optional)...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade200)),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _loading ? null : _submitRating,
          icon: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded),
          label: Text(_loading ? 'Submitting...' : 'Submit Rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        )),
      ]),
    );
  }
}