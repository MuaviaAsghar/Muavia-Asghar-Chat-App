import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Home/home_screen_model.dart';
import '../Models/json_model.dart';
import '../chat_screen/chat_screen_view.dart';


class ChatScreenCard extends StatelessWidget {
  final HomeScreenModel model;
  final ChatUser myuser;

  const ChatScreenCard({required this.model, required this.myuser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        model.isSelectingTile = true;
        model.selectedItems.add(myuser);
      },
      onTap: () {
        if (model.isSelectingTile) {
          if (model.selectedItems.contains(myuser)) {
            model.selectedItems.remove(myuser);
          } else {
            model.selectedItems.add(myuser);
          }
          if (model.selectedItems.isEmpty) {
            model.isSelectingTile = false;
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenView(user: myuser),
            ),
          );
        }
      },
      child: ListTile(
        title: Text(myuser.name),
        subtitle: Text(myuser.email),
        leading: model.isSelectingTile
            ? Checkbox(
                value: model.selectedItems.contains(myuser),
                onChanged: (isChecked) {
                  if (isChecked == true) {
                    model.selectedItems.add(myuser);
                  } else {
                    model.selectedItems.remove(myuser);
                    if (model.selectedItems.isEmpty) {
                      model.isSelectingTile = false;
                    }
                  }
                },
              )
            : null,
      ),
    );
  }
}