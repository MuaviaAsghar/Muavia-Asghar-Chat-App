import 'package:flutter/material.dart';

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({super.key});

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 37, 196, 188),
        centerTitle: true,
        title: const Text("Name of a person we are talking wtih"),
      ),
      body:
          // Container(padding:const EdgeInsets.only(top: 60),
          // child:
          SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
              height: MediaQuery.of(context).size.height / 1.15,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(23))),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2),
                    alignment: Alignment.bottomRight,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10))),
                    child: const Text(
                      "Hi Muavia, how are you?",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(
                      10,
                    ),
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 2),
                    alignment: Alignment.topLeft,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 93, 163, 196),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: const Text(
                      "Hi Muavia,  are you?",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 5.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 3, 138, 75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                              child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter a message",
                                hintStyle: TextStyle(
                                  color: Colors.black45,
                                )),
                          )),
                          Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                color: Colors.grey,
                              ),
                              child: const Center(child: Icon(Icons.send)))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
