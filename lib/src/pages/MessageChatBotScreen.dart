import 'package:flutter/material.dart';

class Contact {
  final String userId;
  final String userName;
  final List conv;
  const Contact({
    required this.userId,
    required this.conv,
    required this.userName,
  });
}

class MessageChatBotScreen extends StatelessWidget {
  final String? phoneUID;

  final List<Contact> contacts = const [
    Contact(
      userId: 'ahs786',
      conv: ['from ', 'Hello Ayaz '],
      userName: 'Ayaz ',
    ),
  ];

  const MessageChatBotScreen({super.key, this.phoneUID});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chat & Support')),
    body: GestureDetector(
      onTap: () {},

      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.amberAccent,
        ),
        height: 80,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?semt=ais_hybrid&w=740&q=80',
              ),
            ),
            SizedBox(width: 20),

            Expanded(
              child: Column(
                children: [
                  Text(
                    "Ayaz Hussain ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Good Morning   "),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
