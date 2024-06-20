import 'package:flutter/material.dart';

class ChatScreenView extends StatefulWidget {
  const ChatScreenView({super.key});

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 37, 196, 188),centerTitle: true,title: Text("Name of a person we are talking wtih"),),
      body: 
      // Container(padding:const EdgeInsets.only(top: 60),
        // child:
         SingleChildScrollView(
           child: Column(
            children: [SizedBox(height: 10,),
              Container(padding: EdgeInsets.only(left:20,right: 20,top: 50),
                height: MediaQuery.of(context).size.height/1.15,
              width: MediaQuery.of(context).size.width,
              decoration:const BoxDecoration(
                borderRadius:BorderRadius.only(topLeft: Radius.circular(30)
              ,topRight: Radius.circular(23)) )
              ,child:Column(children: [Container(padding: EdgeInsets.all(10,),
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/2),
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                color: Colors.grey,borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
                
                )
                )
                ,child: Text("Hi Muavia, how are you?",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),)
             , Container(padding: EdgeInsets.all(10,),
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/2),
                alignment: Alignment.topRight,
                decoration: BoxDecoration(
                color: Colors.grey,borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
                
                )
                )
                ,child: Text("Hi Muavia,  are you?",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),)
                  ],
                ) ,),
            ],
                   ),
         ),
      // ),
    );
  }
}