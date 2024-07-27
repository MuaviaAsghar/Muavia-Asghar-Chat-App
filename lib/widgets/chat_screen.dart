import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:say_anything_to_muavia/Home/home_screen_model.dart';

import '../Models/json_model.dart';
import '../chat_screen/chat_screen_view.dart';

class ChatScreenCard extends StatefulWidget {
  final ChatUser myuser;
  final HomeScreenModel model;

  const ChatScreenCard({
    super.key,
    required this.myuser,
    required this.model,
  });

  @override
  State<ChatScreenCard> createState() => _ChatScreenCardState();
}

class _ChatScreenCardState extends State<ChatScreenCard> {
  void handleSelection(ChatUser user) {
    if (widget.model.selectedItems.contains(user)) {
      log("handle selection callinh");
      widget.model.removeSelectedItem(user);
      setState(() {});
    } else {
      widget.model.addSelectedItem(user);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.myuser;

    return InkWell(
      onLongPress: () {
        handleSelection(user);
      },
      onTap: () {
        if (widget.model.isSelectingTile) {
          handleSelection(user);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => ChatScreenView(
                        user: user,
                      )));
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
        elevation: 1,
        child: Container(
          color: (widget.model.selectedItems.contains(user))
              ? Colors.blue.withOpacity(0.5)
              : null,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(
                  MediaQuery.sizeOf(context).height * .03),
              child: CachedNetworkImage(
                cacheManager: widget.model.customCacheManager,
                key: UniqueKey(),
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
      ),
    );
  }
}
