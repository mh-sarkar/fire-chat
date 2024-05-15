import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_chat/src/provider/home_provider.dart';
import 'package:fire_chat/src/shared/global.dart';
import 'package:flutter/material.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get collection => _firestore.collection('chat_list');

  String lastImage = '';

  void removeImage() {
    lastImage = '';
  }

  // Stream<QuerySnapshot> get allChats => collection.snapshots();

  Stream<QuerySnapshot> getChatList(String chatId) {
    return collection.doc(chatId).collection('chats').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addChat(String chatId, String message) async {
    await collection.doc(chatId).collection('chats').add({
      'sender': globalRef?.read(homeProvider).user!.uid, // 'user1' or 'user2
      'message': message,
      'seen': false, // 'true' or 'false
      'timestamp': DateTime.now(),
    });
  }

  Future<void> updateChat(String chatId, String messageId) async {
    await collection.doc(chatId).collection('chats').doc(messageId).update({
      'seen': true,
    });
  }

  Future<void> firstMessage(String chatId, String message, String receiverId) async {
    await collection.doc(chatId).set({
      'user1': globalRef?.read(homeProvider).user!.uid,
      'user2': receiverId,
      'chat_created': DateTime.now(),
      'last_message': {
        'sender': globalRef?.read(homeProvider).user!.uid,
        'message': message,
        'seen': false,
        'timestamp': DateTime.now(),
      }
    });
    await collection.doc(chatId).collection('chats').add({
      'sender': globalRef?.read(homeProvider).user!.uid,
      'message': message,
      'seen': false,
      'timestamp': DateTime.now(),
    });
  }
}
