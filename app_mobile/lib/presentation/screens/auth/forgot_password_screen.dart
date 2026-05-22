import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/snackbars.dart';
import '../../../core/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    AppSnackbars.info(
      context,
      'Fonctionnalité bientôt disponible. Un email de réinitialisation sera envoyé ici.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_reset_rounded,
                          size: 54,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Réinitialiser le mot de passe',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Entrez votre adresse email pour recevoir les instructions.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Envoyer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
