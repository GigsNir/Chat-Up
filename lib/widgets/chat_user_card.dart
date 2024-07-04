import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_up/api/apis.dart';
import 'package:chat_up/helper/my_date_util.dart';
import 'package:chat_up/main.dart';
import 'package:chat_up/models/chat_user.dart';
import 'package:chat_up/models/message.dart';
import 'package:chat_up/screens/auth/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

    Message ? _message;


  @override
  Widget build(BuildContext context) {
    return Card(

      margin: EdgeInsets.symmetric(horizontal: mq.width *.04, vertical: 4),
      // color:  Color.fromARGB(255, 219, 236, 255),
      elevation:1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: InkWell(
        onTap: () {
          //navigating to chat screen
          Navigator.push(context,MaterialPageRoute(builder: (_)=> ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMesssages(widget.user),
          builder: (context, snapshot){

            final data = snapshot.data?.docs;
            final list= data?.map((e) => Message.fromJson(e.data())).toList()?? [];
            if(list.isNotEmpty)_message = list[0];

            return  ListTile(
          //profile pic
        leading: ClipOval(
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
              fit: BoxFit.cover,
              imageUrl: widget.user.image,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),

          //user name
          title: Text(widget.user.name),

          //last message sent
          subtitle: Text(
            _message != null ?_message!.msg : widget.user.about, 
            maxLines: 1),

          //last message time
            trailing:  _message == null
            ? null 
            :_message!.read.isEmpty &&
              _message!.fromId !=APIs.user.uid
            ?

            //show for unread message
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400, 
                borderRadius: BorderRadius.circular(10) ),
            ):
            Text(
            MyDateUtil.getLastMesssageTime
            (context: context, time: _message!.sent),
            style: const TextStyle(color: Colors.black54),
             ),
            );
          })
      ),
    );
  }
}