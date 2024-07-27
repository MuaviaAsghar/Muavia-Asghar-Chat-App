import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';

import '../Models/json_model.dart';
import '../my_date_util/my_date_util.dart';
import '../widgets/theme.dart';
import '../widgets/theme_provider.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final customcCacheManager = CacheManager(Config('customcachekey',
      stalePeriod: const Duration(days: 30), maxNrOfCacheObjects: 1000));
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: FocusScope.of(context).unfocus,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Provider.of<Themeprovider>(context).themeData == darkmode
                ? [const Color(0xff2b5876), const Color(0xff4e4376)]
                : [const Color(0xfffff1eb), const Color(0xfface0f9)],
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              //app bar
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(widget.user.name)),

              //user about
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Joined On: ',
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15),
                  ),
                  Text(
                      MyDateUtil.getLastMessageTime(
                          context: context,
                          time: widget.user.createdAt,
                          showYear: true),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 15)),
                ],
              ),

              //body
              body: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * .05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // for adding some space
                      SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * .03),

                      //user profile picture
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.sizeOf(context).height * .1),
                        child: CachedNetworkImage(
                          cacheManager: customcCacheManager,
                          key: UniqueKey(),
                          width: MediaQuery.sizeOf(context).height * .2,
                          height: MediaQuery.sizeOf(context).height * .2,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),

                      // for adding some space
                      SizedBox(height: MediaQuery.sizeOf(context).height * .03),

                      // user email label
                      Text(widget.user.email,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16)),

                      // for adding some space
                      SizedBox(height: MediaQuery.sizeOf(context).height * .02),

                      //user about
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'About: ',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          Text(widget.user.about,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
