import 'package:flutter/material.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Dummy orders (backend-ready format)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD1001',
      'title': 'Home AC Repair',
      'status': 'Completed',
      'price': 40,
      'client': 'Ali Khan',
      'date': 'Oct 10, 2025',
      'image': 'https://i.imgur.com/8Km9tLL.png',
      'description':
          'Technician repaired the AC unit and refilled the gas. Cooling is now working perfectly.'
    },
    {
      'id': 'ORD1002',
      'title': 'Plumbing Fix',
      'status': 'Pending',
      'price': 25,
      'client': 'Sara Malik',
      'date': 'Oct 22, 2025',
      'image': 'https://i.imgur.com/QCNbOAo.png',
      'description':
          'The client reported water leakage in the kitchen. The plumber will visit tomorrow morning.'
    },
    {
      'id': 'ORD1003',
      'title': 'Car Wash Service',
      'status': 'In Progress',
      'price': 15,
      'client': 'Hassan Ahmed',
      'date': 'Oct 23, 2025',
      'image': 'https://i.imgur.com/x3M7QyJ.png',
      'description':
          'Car wash is currently being handled at the service center. Estimated completion in 30 minutes.'
    },
    {
      'id': 'ORD1004',
      'title': 'Electric Wiring',
      'status': 'Completed',
      'price': 60,
      'client': 'Fatima Noor',
      'date': 'Oct 20, 2025',
      'image': 'https://i.imgur.com/Yy6zO7R.png',
      'description':
          'New electrical wiring completed successfully with safety inspection and testing.'
    },
    {
      'id': 'ORD1005',
      'title': 'Painting Service',
      'status': 'Cancelled',
      'price': 35,
      'client': 'Usman Tariq',
      'date': 'Oct 12, 2025',
      'image': 'https://i.imgur.com/zYxDCQT.png',
      'description':
          'Client cancelled due to schedule conflict. Partial payment refunded.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      final matchesFilter =
          _selectedFilter == 'All' || order['status'] == _selectedFilter;
      final matchesSearch = order['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order['client']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Manage Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                icon: const Icon(Icons.filter_list, color: Colors.black),
                dropdownColor: Colors.white,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Orders')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  setState(() => _selectedFilter = value!);
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders by service or client...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Orders list
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailPage(order: order),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order['image'],
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
                                    Text(order['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Client: ${order['client']}",
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['date'],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black45),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${order['price']}",
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      order['status'],
                                      style: TextStyle(
                                          color: _statusColor(order['status']),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
