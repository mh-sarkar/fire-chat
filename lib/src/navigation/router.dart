import 'package:fire_chat/src/auth/login_page.dart';
import 'package:fire_chat/src/auth/register_page.dart';
import 'package:fire_chat/src/chat/chat_page.dart';
import 'package:fire_chat/src/home/home_page.dart';
import 'package:fire_chat/src/provider/auth_provider.dart';
import 'package:fire_chat/src/provider/home_provider.dart';
import 'package:fire_chat/src/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mh_ui/mh_ui.dart';

final _key = GlobalKey<NavigatorState>();

enum AppRoute { splash, login, home, register, chat }

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _key,

    /// Forwards diagnostic messages to the dart:developer log() API.
    debugLogDiagnostics: true,

    /// Initial Routing Location
    initialLocation: '/${AppRoute.splash.name}',

    /// The listeners are typically used to notify clients that the object has been
    /// updated.
    refreshListenable: authState,

    routes: [
      GoRoute(
        path: '/${AppRoute.splash.name}',
        name: AppRoute.splash.name,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/${AppRoute.login.name}',
        name: AppRoute.login.name,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/${AppRoute.register.name}',
        name: AppRoute.register.name,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/${AppRoute.chat.name}',
        name: AppRoute.chat.name,
        builder: (context, state) {
          final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
          final String? chatId = extra?['chat_id'] as String?;
          final String? chatName = extra?['chat_name'] as String?;
          return ChatScreen(
            chatId: chatId,
            chatName: chatName,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isLoggedIn;

      globalLogger.d('isAuthenticated: $isAuthenticated');
      globalLogger.d('state.fullPath: ${state.fullPath}');

      if (state.fullPath == '/${AppRoute.splash.name}') {
        return isAuthenticated ? '/' : '/${AppRoute.login.name}';
      }
      return null;
    },
  );
});
