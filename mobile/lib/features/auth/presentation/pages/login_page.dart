import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:telQ_mobile/core/routes/app_route.dart';

import '../cubit/login_cubit.dart';
import '../widgets/glass_button.dart';
import '../widgets/widget_bubble.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        child: Stack(
          children: [
            // Bubble
            const Bubble(size: 160, alignment: Alignment(-1.1, -1.05)),
            const Bubble(size: 140, alignment: Alignment(1.05, -0.7)),
            const Bubble(size: 130, alignment: Alignment(-1.0, 0.95)),
            const Bubble(size: 150, alignment: Alignment(1.1, 1.05)), 

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: BlocListener<LoginCubit, LoginState>(
                        listenWhen: (previous, current) => previous.status != current.status,
                        listener: (context, state) {
                          if (state.status == LoginStatus.success) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: 'Login success',
                              confirmBtnColor: const Color(0xFFF5821F),
                              confirmBtnTextStyle: const TextStyle(color: Colors.white),
                              autoCloseDuration: const Duration(seconds: 2),
                            );
                          } else if (state.status == LoginStatus.failure && state.error != null) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              text: state.error!,
                              confirmBtnColor: const Color(0xFFF5821F),
                              confirmBtnTextStyle: const TextStyle(color: Colors.white),
                              autoCloseDuration: const Duration(seconds: 3),
                            );
                          }
                        },
                        child: BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'WELCOME TO TELQ!',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'User Login',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _Label('Email Address'),
                                TextField(
                                  onChanged: context.read<LoginCubit>().emailChanged,
                                  decoration: _inputDecoration('Email'),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _Label('Password'),
                                TextField(
                                  onChanged: context.read<LoginCubit>().passwordChanged,
                                  decoration: _inputDecoration('Password'),
                                  obscureText: true,
                                ),
                                const SizedBox(height: 24),
                                GlassButton(
                                  label: 'Login',
                                  loading: state.status == LoginStatus.loading,
                                  onPressed: () => context.read<LoginCubit>().submit(),
                                ),
                                if (state.status == LoginStatus.failure && state.error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(state.error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                                ],
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account? "),
                                    TextButton(
                                      onPressed: () => Navigator.pushReplacementNamed(
                                        context,
                                        AppRoute.register.path,
                                      ),
                                      child: const Text('Create here!', style: TextStyle(color: Color(0xFFF5821F))),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0EFEF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
