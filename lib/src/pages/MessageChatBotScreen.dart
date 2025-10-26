import 'package:flutter/material.dart';

class MessageChatBotScreen extends StatelessWidget {
  
  const MessageChatBotScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chat & Support')),
    body: Container(
      decoration: BoxDecoration(color: Color.from(alpha: 12, red: 13, green: 45, blue: 167)),
      
      child: Column(children: [
      Text('Hello Ayaz HUssain ')
      ],),
      ),
  
    
  );
}