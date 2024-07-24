import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  final customCacheManager = CacheManager(Config('customcachekey',
      stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 1000));

  final List<ChatUser> _selectedItems = [];

  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }

  void _handleLongPress() {
    setState(() {
      if (_selectedItems.contains(widget.myuser)) {
        _selectedItems.remove(widget.myuser);
      } else {
        _selectedItems.add(widget.myuser);
      }
    });
  }

  void _handleTap() {
    if (_selectedItems.contains(widget.myuser)) {
      setState(() {
        _selectedItems.remove(widget.myuser);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ChatScreenView(
            user: widget.myuser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = widget.myuser;
    bool isSelected = _selectedItems.contains(user);

    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      elevation: 1,
      color: (isSelected) ? Colors.blue.withOpacity(0.5) : Colors.transparent,
      child: InkWell(
        onLongPress: _handleLongPress,
        onTap: _handleTap,
        child: ListTile(
          leading: ClipRRect(
            borderRadius:
                BorderRadius.circular(MediaQuery.sizeOf(context).height * .03),
            child: CachedNetworkImage(
              cacheManager: customCacheManager,
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
    );
  }
}
