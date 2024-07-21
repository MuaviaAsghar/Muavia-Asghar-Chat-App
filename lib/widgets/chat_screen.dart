import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/json_model.dart';
import '../chat_screen/chat_screen_view.dart';

class ChatScreenCard extends StatefulWidget {
  final ChatUser myuser;

  const ChatScreenCard({
    super.key,
    required this.myuser,
  });

  @override
  State<ChatScreenCard> createState() => _ChatScreenCardState();
}

class _ChatScreenCardState extends State<ChatScreenCard> {
  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.myuser;

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () async {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => ChatScreenView(
                        user: widget.myuser,
                      )));
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius:
                BorderRadius.circular(MediaQuery.sizeOf(context).height * .03),
            child: CachedNetworkImage(
              width: MediaQuery.sizeOf(context).height * .055,
              height: MediaQuery.sizeOf(context).height * .055,
              imageUrl: user.image,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          title: Text(user.name.isNotEmpty ? user.name : 'Unknown User'),
          subtitle: Text(
            user.about.isNotEmpty ? user.about : 'No status',
            maxLines: 1,
          ),
          trailing: user.name == "Chat Bot"
              ? Icon(CupertinoIcons.pin_fill,
                  color: Colors.greenAccent.shade400, size: 18)
              : Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.greenAccent.shade400,
                  ),
                ),
        ),
      ),
    );
  }
}
