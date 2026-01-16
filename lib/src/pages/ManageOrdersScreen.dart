import 'package:flutter/material.dart';

class Order {
  final String id;
  final String title;
  final String price;
  final String description;
  final String sellerId;
  final String orderstatus;
  final String time;
  final String proImg;

  const Order({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.sellerId,
    required this.orderstatus,
    required this.time,
    required this.proImg,
  });
}

class ManageOrdersScreen extends StatelessWidget {
  final String? phoneUID;

  const ManageOrdersScreen({super.key, this.phoneUID});

  final List<Order> orders = const [
    Order(
      id: 'ORD1001',
      title: 'Pro Java Developer',
      price: "30",
      description:
          'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
      sellerId: 'Simmon07',
      orderstatus: 'Completed',
      time: 'Feb 18, 2024',
      proImg: 'https://i.imgur.com/x3M7QyJ.png',
    ),
    Order(
      id: 'ORD1002',
      title: 'Pro Java Developer',
      price: "10",
      description:
          'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
      sellerId: 'Simmon07',
      orderstatus: 'Completed',
      time: 'Feb 18, 2024',
      proImg: 'https://i.imgur.com/x3M7QyJ.png',
    ),
    Order(
      id: 'ORD1003',
      title: 'Pro Java Developer',
      price: "5",
      description:
          'Mastering java GUIs, excelling in MySQL, and delivering top notch projects.',
      sellerId: 'Simmon07',
      orderstatus: 'Completed',
      time: 'Feb 18, 2024',
      proImg: 'https://i.imgur.com/x3M7QyJ.png',
    ),
  ];

  Widget _buildOrderCard(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top section with image, price and description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.proImg,
                    height: 60,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\$${order.price}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // seller info + status chip
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    'https://i.imgur.com/Yy6zO7R.png',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.sellerId,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.orderstatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 15),
          Icon(Icons.filter_list, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        itemCount: orders.length,
        itemBuilder: (context, index) =>
            _buildOrderCard(context, orders[index]),
      ),
    );
  }
}

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  // state to control expansions if you want (optional)
  final Map<String, bool> _expanded = {
    'orderCompleted': false,
    'myReview': false,
    'buyerReview': false,
    'youDelivered': false,
    'orderRequirements': true,
    'orderCreated': false,
  };

  Widget _timelineDot(IconData icon, {Color? color}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: Colors.black54),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _attachmentTile(String name) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.insert_drive_file_outlined),
      title: Text(name),
      subtitle: const Text('docx • 24 KB'),
      trailing: IconButton(
        onPressed: () {
          // TODO: download/open file
        },
        icon: const Icon(Icons.download_rounded),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          order.sellerId,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.black87),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: [
              // top card with thumbnail, title, price, status
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
                      child: Image.network(
                        order.proImg,
                        height: 70,
                        width: 92,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.orderstatus.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${order.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // timeline / events
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // left timeline column
                    Column(
                      children: [
                        _timelineDot(Icons.check_box, color: Colors.white),
                        Container(
                          width: 2,
                          height: 26,
                          color: Colors.grey.shade300,
                        ),
                        _timelineDot(Icons.star_border),
                        Container(
                          width: 2,
                          height: 26,
                          color: Colors.grey.shade300,
                        ),
                        _timelineDot(Icons.person_outline),
                        Container(
                          width: 2,
                          height: 26,
                          color: Colors.grey.shade300,
                        ),
                        _timelineDot(Icons.calendar_today),
                        Container(
                          width: 2,
                          height: 26,
                          color: Colors.grey.shade300,
                        ),
                        _timelineDot(Icons.event_note),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // right detail column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // completed
                          ExpansionTile(
                            initiallyExpanded: _expanded['orderCompleted']!,
                            onExpansionChanged: (v) =>
                                setState(() => _expanded['orderCompleted'] = v),
                            title: const Text(
                              'The order was completed',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'You earned \$4 for this order. Great job, Ayazengima!',
                            ),
                            children: [
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Order details'),
                                subtitle: const Text(
                                  'Completed on Feb 19, 2024 • Delivered',
                                ),
                              ),
                            ],
                          ),

                          // my review
                          ExpansionTile(
                            initiallyExpanded: _expanded['myReview']!,
                            onExpansionChanged: (v) =>
                                setState(() => _expanded['myReview'] = v),
                            title: const Text(
                              'My review',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('You haven\'t left a review yet.'),
                                    SizedBox(height: 8),
                                    Text('Rate the buyer and leave feedback.'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // buyer review
                          ExpansionTile(
                            initiallyExpanded: _expanded['buyerReview']!,
                            onExpansionChanged: (v) =>
                                setState(() => _expanded['buyerReview'] = v),
                            title: const Text(
                              'Buyer review',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Buyer left a 5-star review. Great communication',
                                ),
                              ),
                            ],
                          ),

                          // delivered
                          ExpansionTile(
                            initiallyExpanded: _expanded['youDelivered']!,
                            onExpansionChanged: (v) =>
                                setState(() => _expanded['youDelivered'] = v),
                            title: const Text(
                              'You delivered the order',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text('Delivered files attached below.'),
                              ),
                            ],
                          ),

                          // delivery date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Your delivery date was updated to 2/19/24',
                            ),
                          ),

                          // Order started (collapsible)
                          ExpansionTile(
                            initiallyExpanded:
                                _expanded['orderStarted'] ?? false,
                            title: const Text(
                              'Order started',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text('Order started on Feb 12, 2024'),
                              ),
                            ],
                          ),

                          const Divider(),

                          // Order Requirements submitted (big section)
                          _buildSectionTitle(
                            'Order requirements submitted',
                            subtitle: '',
                          ),
                          const SizedBox(height: 8),

                          // A list of typical Q/A fields like Fiverr
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'What is the purpose of your project?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'As we discuss',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Can you provide a detailed description of your project?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                _attachmentTile('Assignment 2.docx'),
                                const SizedBox(height: 6),
                                const Text(
                                  'Who is your target audience or end-users?',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'As we discuss',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Do you have any design preferences or examples in mind? Note create pdf file and attach images that clearly explain your ideas or design',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                _attachmentTile('Design-Reference.pdf'),
                                const SizedBox(height: 10),
                                const Text(
                                  'Any additional information you want to give',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'As we discuss',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Order created section
                          ExpansionTile(
                            initiallyExpanded: _expanded['orderCreated']!,
                            onExpansionChanged: (v) =>
                                setState(() => _expanded['orderCreated'] = v),
                            title: const Text(
                              'Order created',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Order created on Feb 12, 2024 by Simmon07',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // floating message bubble with avatar positioned bottom right
          Positioned(
            right: 16,
            bottom: 18,
            child: GestureDetector(
              onTap: () {
                // Open chat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open chat / message screen')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://i.imgur.com/Yy6zO7R.png',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Message',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
