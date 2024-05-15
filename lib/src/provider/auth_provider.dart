import 'package:fire_chat/src/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = ChangeNotifierProvider((ref) => AuthController());
