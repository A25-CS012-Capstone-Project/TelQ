import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telq_mobile/core/routes/app_route.dart';
import 'package:telq_mobile/core/widgets/glass_button.dart';

import '../cubit/register_cubit.dart';
import '../widgets/widget_bubble.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2E9),
      body: SafeArea(
        child: Stack(
          children: [
            const Bubble(size: 160, alignment: Alignment(-1.05, -1.05)),
            const Bubble(size: 140, alignment: Alignment(1.05, -0.75)),
            const Bubble(size: 130, alignment: Alignment(-1.0, 0.95)),
            const Bubble(size: 150, alignment: Alignment(1.05, 1.05)),
            const _RegisterForm(),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveUserData(RegisterState state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.user != null) {
      await prefs.setString('customer_id', state.user!.customerId);
      await prefs.setString('user_name', state.user!.firstname);
      await prefs.setString('user_email', state.user!.email);
    } else {
      // Fallback to form data if user object not available
      await prefs.setString('customer_id', state.customerId);
      await prefs.setString('user_name', state.firstname);
      await prefs.setString('user_email', state.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
              child: BlocListener<RegisterCubit, RegisterState>(
                listenWhen: (prev, curr) => prev.status != curr.status,
                listener: (context, state) {
                  if (state.status == RegisterStatus.success) {
                    // Save user data to SharedPreferences
                    _saveUserData(state);
                    
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text: 'Registration success',
                      confirmBtnColor: const Color(0xFFF5821F),
                      confirmBtnTextStyle: const TextStyle(color: Colors.white),
                      autoCloseDuration: const Duration(seconds: 2),
                    ).then((_) {
                      // Navigate to questionnaire after dialog closes
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoute.questionnaire.path,
                          (route) => false,
                        );
                      }
                    });
                  } else if (state.status == RegisterStatus.failure && state.error != null) {
                    final isExists = state.error!.toLowerCase().contains('exist');
                    QuickAlert.show(
                      context: context,
                      type: isExists ? QuickAlertType.warning : QuickAlertType.error,
                      text: state.error!,
                      confirmBtnColor: const Color(0xFFF5821F),
                      confirmBtnTextStyle: const TextStyle(color: Colors.white),
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                  }
                },
                child: BlocBuilder<RegisterCubit, RegisterState>(
                  buildWhen: (previous, current) => previous.status != current.status,
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create an Account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Label('Name'),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: _firstNameFocusNode,
                                onChanged: context.read<RegisterCubit>().firstnameChanged,
                                decoration: _inputDecoration('First Name'),
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _lastNameFocusNode.requestFocus(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                focusNode: _lastNameFocusNode,
                                onChanged: context.read<RegisterCubit>().lastnameChanged,
                                decoration: _inputDecoration('Last Name'),
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => _emailFocusNode.requestFocus(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Label('Email'),
                        TextField(
                          focusNode: _emailFocusNode,
                          onChanged: context.read<RegisterCubit>().emailChanged,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        _Label('Password'),
                        TextField(
                          focusNode: _passwordFocusNode,
                          onChanged: context.read<RegisterCubit>().passwordChanged,
                          decoration: _inputDecoration('Password'),
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _phoneFocusNode.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        _Label('No Telp'),
                        TextField(
                          focusNode: _phoneFocusNode,
                          onChanged: context.read<RegisterCubit>().customerIdChanged,
                          decoration: _inputDecoration('08xxxxx'),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        GlassButton(
                          label: 'Create',
                          loading: state.status == RegisterStatus.loading,
                          onPressed: () => context.read<RegisterCubit>().submit(),
                        ),
                        if (state.status == RegisterStatus.failure && state.error != null) ...[
                          const SizedBox(height: 12),
                          Text(state.error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an Account? '),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoute.login.path,
                              ),
                              child: const Text('Login here!', style: TextStyle(color: Color(0xFFF5821F))),
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
