

import 'dart:io';

import 'package:chat_up/models/chat_user.dart';
import 'package:chat_up/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:developer';

class APIs {
  // Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // Firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;



  static User get user => auth.currentUser!;

  // Firestore storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //storing self information
  static late ChatUser me;

  //check if user exists or not 
  static Future <bool> userExists() async{
    return (await firestore
    .collection('users')
    .doc(user.uid)
    .get())
    .exists;
  }

  //getting user info

  static Future <void> getSelfInfo() async{
    await firestore
    .collection('users')
    .doc(user.uid)
    .get()
    .then((user) async {
      if (user.exists){
        me = ChatUser.fromJson(user.data()!);
      }
      else{
        await createUser().then((value) => getSelfInfo());
      }

    });
    
  }

  //creating new user
  static Future <void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser (
      id: user.uid, 
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey",
      image: user.photoURL.toString(),
      createdAt: time ,
      isOnline: false,
      lastActive: time ,
      pushToken: ''
      );

    return (await firestore
    .collection('users')
    .doc(user.uid)
    .set(chatUser.toJson())
    );
    

   
  }


//getting all user from database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users')
    .where('id', isNotEqualTo: user.uid)
    .snapshots();
  }

   //updating user information 
  static Future <void> updateUserInfo() async{
    await firestore
    .collection('users')
    .doc(user.uid)
    .update({
      'name': me.name,
      'about': me.about,
    });
    
  }

  //update profile pic
  static Future<void> updateProfilePicture(File file) async{
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref 
    .putFile(file, SettableMetadata(contentType: 'image/$ext'))
    .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in database
    me.image = await ref.getDownloadURL();
    await firestore 
    .collection('users')
    .doc(user.uid)
    .update ({'image': me.image});
  }

  ///************** Chat Screen Related APIs **************

  //for getting conversation id
  static String getConversationID(String id) =>user.uid.hashCode <= id.hashCode
  ? '${user.uid}_$id'
  : '${id}_${user.uid}';


  //for getting all messages of a specific conversation from firestore database
   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMesssages(
    ChatUser chatUser){
    return firestore 
    .collection('chats/${getConversationID(chatUser.id)}/messages/')
    .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async{
    //message sending time
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
      msg: msg, 
      toId: chatUser.id, 
      read: '', 
      type: Type.text, 
      sent: time, 
      fromId: user.uid);

    final ref = firestore
      .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

   //update read status of message
   static Future<void> updateMessageReadStatus(Message message) async {
     firestore
         .collection('chats/${getConversationID(message.fromId)}/messages/')
         .doc(message.sent)
         .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
   }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMesssages(
    ChatUser chatUser){
    return firestore 
    .collection('chats/${getConversationID(chatUser.id)}/messages/')
    .orderBy('sent', descending: true)
    .limit(1)
    .snapshots();
  }




}

