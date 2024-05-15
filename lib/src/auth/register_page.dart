import 'package:fire_chat/src/navigation/router.dart';
import 'package:fire_chat/src/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mh_ui/mh_ui.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends HookWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    return Consumer(builder: (BuildContext context, ref, Widget? child) {
      final auth = ref.read(authProvider);
      void registerWithEmailAndPassword() async {
        try {
          await auth.signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
        } catch (e) {
          globalLogger.e("Error logging in: $e");
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            marginHorizontal: 0,
            controller: emailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          CustomTextField(
            marginHorizontal: 0,
            controller: passwordController,
            labelText: 'Password',
            obscureText: true,
            isPassword: true,
          ),
          CustomButton(
            label: 'Register',
            marginHorizontal: 0,
            marginVertical: 12,
            onPressed: registerWithEmailAndPassword,
          ),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.go('/${AppRoute.login.name}');
            },
            child: const Text('Already have an account'),
          ),
        ],
      );
    });
  }
}
