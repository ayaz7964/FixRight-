
  /// Format last seen timestamp for presence display
  String _formatLastSeen(Timestamp timestamp) {
    final lastSeenDate = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      final time = DateFormat('HH:mm').format(lastSeenDate);
      return 'Last seen yesterday at $time';
    } else if (difference.inDays < 7) {
      final time = DateFormat('HH:mm').format(lastSeenDate);
      final day = DateFormat('EEEE').format(lastSeenDate);
      return 'Last seen $day at $time';
    } else {
      return 'Last seen ${DateFormat('MMM d').format(lastSeenDate)}';
    }
  }
