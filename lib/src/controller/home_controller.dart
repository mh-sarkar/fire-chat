import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mh_ui/mh_ui.dart';

class HomeController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get collection => _firestore.collection('users');

  Stream<QuerySnapshot> get users => collection.snapshots();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;

  User? get user => _user;

  getAuthUser() {
    globalLogger.d('getAuthUser I am calling');
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;

      globalLogger.d('_user: $_user');
      notifyListeners();
    });
  }

  getAllUsers() {
    return collection.snapshots();
  }

  getChatList() {
    return collection.doc(_user!.uid).collection('chat_list').snapshots();
  }
}
