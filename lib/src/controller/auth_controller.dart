import 'package:fire_chat/src/provider/auth_provider.dart';
import 'package:fire_chat/src/provider/chat_provider.dart';
import 'package:fire_chat/src/provider/home_provider.dart';
import 'package:fire_chat/src/shared/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mh_ui/mh_ui.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;

  AuthController() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) globalRef?.read(homeProvider).getAuthUser();
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;

  User? get user => _user;

  Future<void> signIn({required String email, required String password}) async {
    final data = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    globalLogger.d('User: ${data.user}');
    globalRef?.read(homeProvider).getAuthUser();
  }

  Future<void> signUp({required String email, required String password}) async {
    final data = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    globalRef?.read(homeProvider).collection.doc(data.user!.uid).set({
      'email': email,
      'chat_list': [],
    });
    globalRef?.read(homeProvider).getAuthUser();

    globalLogger.d('User: ${data.user}');
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
