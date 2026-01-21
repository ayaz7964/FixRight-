import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallsListScreen extends StatefulWidget {
  const CallsListScreen({super.key});

  @override
  State<CallsListScreen> createState() => _CallsListScreenState();
}

class _CallsListScreenState extends State<CallsListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _currentUserId;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('calls')
            .where('participants', arrayContains: _currentUserId)
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: const Color(0xFF2B7CD3)),
            );
          }

          final calls = snapshot.data?.docs ?? [];

          if (calls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_outlined, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No calls yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your call history will appear here',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final callDoc = calls[index];
              final callData = callDoc.data() as Map<String, dynamic>;

              return _buildCallTile(callData, callDoc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildCallTile(Map<String, dynamic> callData, String callId) {
    final otherParticipant =
        (callData['participants'] as List<dynamic>?)?.firstWhere(
          (p) => p != _currentUserId,
          orElse: () => 'Unknown',
        ) ??
        'Unknown';

    final callType = callData['callType'] ?? 'unknown';
    final duration = callData['duration'] ?? 0; // in seconds
    final timestamp = callData['timestamp'] as Timestamp?;
    final status = callData['status'] ?? 'missed';

    final isIncoming = callData['receiverId'] == _currentUserId;
    final isMissed = status == 'missed';

    return GestureDetector(
      onLongPress: () => _showCallOptions(callId),
      child: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2B7CD3),
              child: Text(
                otherParticipant.isNotEmpty
                    ? otherParticipant.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Call info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and call type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherParticipant,
                          style: TextStyle(
                            fontWeight: isMissed
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 14,
                            color: isMissed
                                ? Colors.red
                                : (_isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      Icon(
                        callType == 'video' ? Icons.videocam : Icons.call,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Call details
                  Row(
                    children: [
                      Icon(
                        isIncoming
                            ? (isMissed ? Icons.call_received : Icons.call_made)
                            : Icons.call_made,
                        size: 12,
                        color: isMissed
                            ? Colors.red
                            : (isIncoming ? Colors.green : Colors.grey[500]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMissed
                            ? 'Missed call'
                            : duration > 0
                            ? '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}'
                            : isIncoming
                            ? 'Incoming'
                            : 'Outgoing',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMissed ? Colors.red : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Time
            Text(
              _formatCallTime(timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),

            const SizedBox(width: 8),

            // Call button
            IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF2B7CD3)),
              onPressed: () {
                // Initiate call
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Calling...')));
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCallTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[date.weekday % 7];
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showCallOptions(String callId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Call Details'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Contact'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
