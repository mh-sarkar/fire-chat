import 'package:fire_chat/src/navigation/router.dart';
import 'package:fire_chat/src/shared/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mh_ui/mh_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  snackbarKey = GlobalKey<ScaffoldMessengerState>();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final router = ref.watch(routerProvider);
    globalRef = ref;
    return MaterialApp.router(
      title: 'Fire Chat',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: snackbarKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
