// lib/src/pages/order_detail_page.dart
import 'package:flutter/material.dart';

class OrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final Map<String, bool> _expanded = {
    'orderCompleted': false,
    'myReview': false,
    'buyerReview': false,
    'youDelivered': false,
    'orderRequirements': true,
    'orderCreated': false,
    'attachments': true,
  };

  Color _statusColor(String? status) {
    switch ((status ?? '').toString().toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'delivered':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.deepPurple;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'in review':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _fmtDate(dynamic at) {
    if (at == null) return '';
    if (at is DateTime) {
      final d = at;
      final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '${_monthName(d.month)} ${d.day}, ${d.year} • $hour:${d.minute.toString().padLeft(2, '0')} $ampm';
    }
    return at.toString();
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (m < 1 || m > 12) return '';
    return names[m];
  }

  Widget _timelineDot(IconData icon, {Color? color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color ?? Colors.black54),
    );
  }

  Widget _attachmentTile(Map<String, dynamic> a) {
    final name = a['name'] ?? 'file';
    final mime = a['mime'] ?? '';
    final size = a['sizeBytes'] ?? a['size'] ?? 0;
    final kb = (size is int) ? (size / 1024).round() : 0;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$mime • ${kb} KB', style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open/download: $name')),
          );
        },
        icon: const Icon(Icons.download_rounded),
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimeline(Map<String, dynamic> order) {
    // If order['timeline'] present and is list, normalize and return
    final t = order['timeline'];
    if (t is List && t.isNotEmpty) {
      return t.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        // if simple strings
        return {'title': e.toString(), 'subtitle': '', 'at': order['date'] ?? ''};
      }).toList();
    }

    // Auto-generate timeline based on status and fields
    final List<Map<String, dynamic>> out = [];

    // order created (use createdAt or date)
    out.add({
      'title': 'Order created',
      'subtitle': 'Client placed the order',
      'at': order['createdAt'] ?? order['date'] ?? ''
    });

    final status = (order['status'] ?? '').toString().toLowerCase();

    // Common optional events pulled from order map
    if (order.containsKey('startedAt')) {
      out.add({
        'title': 'Order started',
        'subtitle': 'Work started by provider',
        'at': order['startedAt']
      });
    }

    if (status == 'in progress' || status == 'pending') {
      out.add({
        'title': 'Work in progress',
        'subtitle': 'Provider is working on the order',
        'at': order['updatedAt'] ?? ''
      });
    }

    if (order.containsKey('deliveredAt') || status == 'delivered' || status == 'completed' || order.containsKey('delivered')) {
      out.add({
        'title': 'You delivered the order',
        'subtitle': order['deliveredNote'] ?? 'Files / deliverables were uploaded',
        'at': order['deliveredAt'] ?? order['delivered'] ?? ''
      });
    }

    if (status == 'completed') {
      final earned = order['earned'] ?? order['revenue'] ?? order['provider_earned'];
      out.add({
        'title': 'The order was completed',
        'subtitle': earned != null
            ? 'You earned \$${earned.toString()} for this order.'
            : 'Order marked completed.',
        'at': order['completedAt'] ?? ''
      });
    }

    if (status == 'in review') {
      out.add({'title': 'In review', 'subtitle': 'Buyer is reviewing the delivery', 'at': ''});
    }

    if (status == 'cancelled' || status == 'canceled') {
      final reason = order['cancellation_reason'] ?? order['cancel_reason'] ?? 'No reason provided';
      out.add({'title': 'Order cancelled', 'subtitle': reason, 'at': order['cancelledAt'] ?? ''});
    }

    // Buyer or seller review events if present
    if (order.containsKey('buyer_review')) {
      final br = order['buyer_review'];
      out.add({
        'title': 'Buyer review',
        'subtitle': (br is Map && br.containsKey('text')) ? br['text'] : br.toString(),
        'at': (br is Map ? br['at'] : '')
      });
    }
    if (order.containsKey('seller_review')) {
      final sr = order['seller_review'];
      out.add({
        'title': 'My review',
        'subtitle': (sr is Map && sr.containsKey('text')) ? sr['text'] : sr.toString(),
        'at': (sr is Map ? sr['at'] : '')
      });
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> order = widget.order;

    final imageUrl = order['image'] ?? order['thumbnail'] ?? '';
    final title = order['title'] ?? 'Order';
    final client = order['client'] ?? order['buyer'] ?? order['seller'] ?? 'Client';
    final status = order['status'] ?? '';
    final price = order['price'] ?? '';
    final description = order['description'] ?? '';
    final requirements = order['requirements'];
    final attachments = order['attachments'];
    final timeline = _buildTimeline(order);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(client,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              // placeholder menu
            },
            icon: const Icon(Icons.more_vert, color: Colors.black87),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: [
              // Header with thumbnail, title, short desc, status chip & price
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != ''
                          ? Image.network(
                              imageUrl,
                              width: 92,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(width: 92, height: 70, color: Colors.grey[200]),
                            )
                          : Container(width: 92, height: 70, color: Colors.grey[200]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text(description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  status.toString(),
                                  style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                              ),
                              const Spacer(),
                              Text('\$${price.toString()}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Timeline / events
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // left timeline icons
                    Column(
                      children: [
                        for (int i = 0; i < timeline.length; i++) ...[
                          _timelineDot(_iconForTimeline(timeline[i]['title']), color: Colors.blue),
                          if (i != timeline.length - 1)
                            Container(width: 2, height: 26, color: Colors.grey.shade300),
                        ],
                      ],
                    ),

                    const SizedBox(width: 12),

                    // right detail column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: timeline.map<Widget>((e) {
                          final tTitle = e['title'] ?? '';
                          final tSub = e['subtitle'] ?? '';
                          final tAt = e['at'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(tTitle,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 14))),
                                  if (tAt != null && tAt.toString().trim() != '')
                                    Text(_fmtDate(tAt),
                                        style: const TextStyle(
                                            color: Colors.black38, fontSize: 12)),
                                ]),
                                if (tSub != null && tSub.toString().trim() != '')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child:
                                        Text(tSub, style: const TextStyle(color: Colors.black54)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Revenue & Reviews block (dynamic)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((order['earned'] ?? order['revenue'] ?? order['provider_earned']) != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                                child: Text('You earned', style: TextStyle(fontWeight: FontWeight.bold))),
                            Text('\$${(order['earned'] ?? order['revenue'] ?? order['provider_earned']).toString()}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                    // Buyer review summary
                    if (order.containsKey('buyer_review')) ...[
                      const Divider(),
                      const Text('Buyer review', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _reviewTile(order['buyer_review'], isBuyer: true),
                    ],

                    // Seller (my) review
                    if (order.containsKey('seller_review')) ...[
                      const Divider(),
                      const Text('My review', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _reviewTile(order['seller_review'], isBuyer: false),
                    ],

                    // Cancellation reason
                    if ((order['status'] ?? '').toString().toLowerCase() == 'cancelled' ||
                        (order['status'] ?? '').toString().toLowerCase() == 'canceled') ...[
                      const Divider(),
                      const Text('Cancellation reason', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(order['cancellation_reason'] ??
                          order['cancel_reason'] ??
                          'No reason provided.'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Requirements & Attachments
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                        child: Text('Order requirements submitted',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: Icon(_expanded['orderRequirements'] == true
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onPressed: () => setState(() =>
                            _expanded['orderRequirements'] = !_expanded['orderRequirements']!),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    if (_expanded['orderRequirements'] == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (requirements is Map && requirements.isNotEmpty)
                            for (final kv in requirements.entries) ...[
                              Text(kv.key.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(kv.value.toString(), style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 12),
                            ]
                          else
                            const Text('No requirements provided.', style: TextStyle(color: Colors.black54)),

                          if (attachments is List && attachments.isNotEmpty) ...[
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Attachments', style: TextStyle(fontWeight: FontWeight.w700)),
                                IconButton(
                                  icon: Icon(_expanded['attachments'] == true
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                                  onPressed: () => setState(
                                      () => _expanded['attachments'] = !_expanded['attachments']!),
                                ),
                              ],
                            ),
                            if (_expanded['attachments'] == true)
                              for (final a in attachments)
                                if (a is Map<String, dynamic>)
                                  _attachmentTile(a)
                                else if (a is String)
                                  _attachmentTile({'name': a, 'mime': '', 'sizeBytes': 0}),
                          ],
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),

          // Floating message bubble
          Positioned(
            right: 16,
            bottom: 18,
            child: GestureDetector(
              onTap: () {
                // placeholder for chat
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Open chat / message screen')));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6))
                    ]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: imageUrl != '' ? NetworkImage(imageUrl) : null,
                      child: imageUrl == '' ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Message', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForTimeline(String? title) {
    final t = (title ?? '').toLowerCase();
    if (t.contains('deliver') || t.contains('delivered')) return Icons.local_shipping_outlined;
    if (t.contains('review')) return Icons.star_border;
    if (t.contains('completed')) return Icons.check_circle_outline;
    if (t.contains('cancel')) return Icons.cancel_outlined;
    if (t.contains('start') || t.contains('created') || t.contains('placed')) return Icons.event_note;
    return Icons.circle_outlined;
  }

  Widget _reviewTile(dynamic review, {required bool isBuyer}) {
    // review can be string or map {rating, text, at}
    String ratingText = '';
    String text = '';
    String at = '';

    if (review is Map<String, dynamic>) {
      ratingText = review['rating'] != null ? '${review['rating']}/5' : '';
      text = review['text'] ?? '';
      at = review['at'] != null ? _fmtDate(review['at']) : '';
    } else if (review != null) {
      text = review.toString();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isBuyer ? Icons.person_outline : Icons.person, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (ratingText != '') Text(ratingText, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (text != '') Padding(padding: const EdgeInsets.only(top: 6), child: Text(text)),
            if (at != '') Padding(padding: const EdgeInsets.only(top: 6), child: Text(at, style: const TextStyle(color: Colors.black38, fontSize: 12))),
          ]),
        ),
      ],
    );
  }
}
