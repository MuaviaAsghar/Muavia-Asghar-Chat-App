import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Home/home_screen_model.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenModel>(
      builder: (BuildContext context, model, Widget? child) {
        return model.isSelectingTile
            ? AppBar(
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () {
                      model.clearSelectedItems();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
                leading: IconButton(
                  onPressed: () {
                    model.clearSelectedItems();
                  },
                  icon: const Icon(CupertinoIcons.clear_circled_solid),
                ),
              )
            : AppBar(
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () {
                      model.toggleSearching();
                    },
                    icon: Icon(model.isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search),
                  )
                ],
                title: model.isSearching
                    ? TextField(
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name, Email, ...'),
                        autofocus: true,
                        style:
                            const TextStyle(fontSize: 16, letterSpacing: 0.5),
                        onChanged: (val) {
                          model.searchlist.clear();
                          for (var i in model.list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                              model.searchlist.add(i);
                            }
                          }
                        },
                      )
                    : const Text("ChatApp"),
                centerTitle: true,
              );
      },
    );
  }
}
