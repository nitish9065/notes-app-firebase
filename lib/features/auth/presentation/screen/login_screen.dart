import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_contants.dart';
import 'package:notes_app/core/providers/app_provider.dart';
import 'package:notes_app/features/auth/presentation/widgets/sign_in_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppContants.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppContants.appLogoPath,
              height: 300,
              width: 200,
            ),
            const SizedBox(
              height: 50,
            ),
            SignInButton(
              icon: Icons.g_mobiledata_outlined,
              text: 'Sign in with Google',
              onPressed: ref.read(authProvider).signInWithGoogle,
            ),
            const SizedBox(
              height: 25,
            ),
            if (Platform.isIOS)
              SignInButton(
                icon: Icons.apple,
                text: 'Sign in with Apple',
                onPressed: ref.read(authProvider).signInWithApple,
              )
          ],
        ),
      ),
    );
  }
}
