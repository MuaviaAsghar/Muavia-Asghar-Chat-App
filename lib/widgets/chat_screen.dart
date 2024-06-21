import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/chat_screen/chat_screen_view.dart';

class ChatScreenCard extends StatefulWidget {
  final String name;
  final String firstLetter;
  final String lastMessage;
  const ChatScreenCard(
      {super.key,
      required this.name,
      required this.firstLetter,
      required this.lastMessage});

  @override
  State<ChatScreenCard> createState() => _ChatScreenCardState();
}

class _ChatScreenCardState extends State<ChatScreenCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => const ChatScreenView()));
        },
        child: ListTile(
          leading: CircleAvatar(
            child: Text(widget.firstLetter),
          ),
          title: Text(widget.name),
          subtitle: Text(
            widget.lastMessage,
            maxLines: 1,
          ),
          trailing: const Text("12:00 Pm"),
        ),
      ),
    );
  }
}
