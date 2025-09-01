import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import 'login_email_field.dart';
import 'login_password_field.dart';
import 'login_button.dart';
import 'login_register_link.dart';
import 'demo_credentials_card.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final Animation<Offset> slideAnimation;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.slideAnimation,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoginEmailField(
                          controller: emailController,
                          focusNode: emailFocus,
                          formKey: formKey,
                        ),
                        const SizedBox(height: 20),
                        LoginPasswordField(
                          controller: passwordController,
                          focusNode: passwordFocus,
                          formKey: formKey,
                        ),
                        const SizedBox(height: 32),
                        LoginButton(onPressed: onLogin),
                        const SizedBox(height: 24),
                        const LoginRegisterLink(),
                        const Spacer(),
                        const DemoCredentialsCard(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}