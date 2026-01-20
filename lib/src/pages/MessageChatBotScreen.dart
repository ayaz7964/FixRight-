import 'package:flutter/material.dart';
import 'ChatListScreen.dart';

class MessageChatBotScreen extends StatefulWidget {
  final String? phoneUID;

  const MessageChatBotScreen({super.key, this.phoneUID});

  @override
  State<MessageChatBotScreen> createState() => _MessageChatBotScreenState();
}

class _MessageChatBotScreenState extends State<MessageChatBotScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace Chat'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main messaging card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B7CD3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Color(0xFF2B7CD3),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Direct Messages',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Chat with buyers, sellers, and support',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Features showcase
            Text(
              'Messenger Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFeatureCard(
                      icon: Icons.message,
                      title: 'Instant Messages',
                      description: 'Send and receive messages in real-time',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: Icons.call,
                      title: 'Audio Calls',
                      description: 'Make crystal clear audio calls',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: Icons.translate,
                      title: 'Auto-Translation',
                      description:
                          'Messages automatically translated to your preferred language',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: Icons.done_all,
                      title: 'Message Status',
                      description: 'Know when your message is sent, delivered, or read',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: Icons.schedule,
                      title: 'Typing Indicators',
                      description: 'See when someone is typing',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2B7CD3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2B7CD3).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supported Languages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _LanguageBadge('English', 'en'),
                      _LanguageBadge('Urdu', 'ur'),
                      _LanguageBadge('Spanish', 'es'),
                      _LanguageBadge('French', 'fr'),
                      _LanguageBadge('Arabic', 'ar'),
                      _LanguageBadge('Hindi', 'hi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2B7CD3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2B7CD3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  final String name;
  final String code;

  const _LanguageBadge(this.name, this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2B7CD3).withOpacity(0.5),
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2B7CD3),
        ),
      ),
    );
  }
}

