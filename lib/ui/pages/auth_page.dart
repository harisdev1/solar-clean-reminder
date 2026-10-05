import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_keys.dart';
import '../../core/app_strings.dart';
import '../../cubit/app_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../widgets/expressive_button.dart';
import '../widgets/prefs_controls.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _signup = false, _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<AppCubit>();
    final busy = context.select((AppCubit c) => c.state.busy);
    context.watch<LocaleCubit>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    AppKeys.logoAsset,
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                          begin: const Offset(.86, .86),
                          curve: Curves.easeOutBack,
                          duration: 600.ms),
                  const SizedBox(height: 16),
                  const LanguagePicker(compact: true),
                  const SizedBox(height: 16),
                  Text(AppStrings.appName,
                      style: tt.displaySmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                      _signup
                          ? AppStrings.signupSubtitle
                          : AppStrings.loginSubtitle,
                      style: tt.bodyLarge
                          ?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: AppStrings.email,
                        prefixIcon: const Icon(Icons.mail_rounded)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_hide
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                  ),
                  if (!_signup)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => cubit.resetPassword(_email.text),
                        child: Text(AppStrings.forgotPassword),
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                  ExpressiveButton(
                    label: _signup
                        ? AppStrings.createAccount
                        : AppStrings.login,
                    busy: busy,
                    onPressed: () => _signup
                        ? cubit.signUp(_email.text, _pass.text)
                        : cubit.signIn(_email.text, _pass.text),
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(AppStrings.or)),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 18),
                  ExpressiveButton(
                    label: AppStrings.continueWithGoogle,
                    icon: Icons.g_mobiledata_rounded,
                    kind: BtnKind.tonal,
                    onPressed: busy ? null : () => cubit.google(),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _signup = !_signup),
                    child: Text(_signup
                        ? AppStrings.haveAccountLogin
                        : AppStrings.newUserSignup),
                  ),
                ]
                    .animate(interval: 55.ms)
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: .1, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
