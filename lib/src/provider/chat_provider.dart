import 'package:fire_chat/src/controller/chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatProvider = ChangeNotifierProvider((ref) => ChatController());
