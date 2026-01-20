import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AudioCallScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const AudioCallScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  late DateTime _callStartTime;
  bool _isCallEnded = false;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    _startCallTimer();
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isCallEnded && mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
        });
        _startCallTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with user info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      widget.receiverName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<Duration>(
                    stream: _buildCallDurationStream(),
                    builder: (context, snapshot) {
                      return Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Call controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                  ),

                  // Speaker button
                  _buildControlButton(
                    icon: _isSpeakerOn
                        ? Icons.volume_up
                        : Icons.volume_down,
                    label: _isSpeakerOn ? 'Speaker On' : 'Speaker Off',
                    onPressed: () {
                      setState(() => _isSpeakerOn = !_isSpeakerOn);
                    },
                  ),

                  // End call button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[700],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _endCall,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[700],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours == 0) {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }

  Stream<Duration> _buildCallDurationStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => _callDuration,
    );
  }

  void _endCall() {
    setState(() => _isCallEnded = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Call Ended'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Caller: ${widget.receiverName}'),
            Text('Duration: ${_formatDuration(_callDuration)}'),
            Text(
              'End Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
