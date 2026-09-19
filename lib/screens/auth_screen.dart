import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/app_icon.dart';

import '../providers/settings_provider.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login
          ? AuthMode.register
          : AuthMode.login;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final shiftProvider = context.read<ShiftProvider>();
      final l = AppLocalizations.of(context)!;

      if (_authMode == AuthMode.login) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authProvider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (!mounted) return;

      // Check for sync conflict
      final remoteShifts = await ApiService().getShifts(authProvider.token!);
      bool? keepLocal;

      if (remoteShifts.isNotEmpty && shiftProvider.shifts.isNotEmpty) {
        if (mounted) {
          keepLocal = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text(l.auth_sync_dialog_title),
              content: Text(l.auth_sync_dialog_content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l.auth_sync_dialog_cloud),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.auth_sync_dialog_local),
                ),
              ],
            ),
          );
        }
      }

      await shiftProvider.syncWithServer(keepLocal: keepLocal);

      if (!mounted) return;
      UIUtils.showSnackBar(
        context,
        _authMode == AuthMode.login
            ? l.auth_login_success
            : l.auth_register_success,
      );

      Navigator.pop(context); // Return to settings
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        UIUtils.showSnackBar(context, l.auth_error_generic, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isLogin = _authMode == AuthMode.login;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EssentialWorkIcon(
                    size: 80,
                    symbol: context.watch<SettingsProvider>().currencySymbol,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isLogin ? l.auth_login_title : l.auth_register_title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        label: l.auth_full_name_label,
                        icon: Icons.person_outline,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? l.auth_error_name_empty
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      label: l.auth_email_label,
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return l.auth_error_email_invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: _buildInputDecoration(
                      label: l.auth_password_label,
                      icon: Icons.lock_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return l.auth_error_password_length;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isLogin
                                  ? l.auth_login_button
                                  : l.auth_register_button,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _switchAuthMode,
                    child: Text(
                      isLogin
                          ? l.auth_no_account_link
                          : l.auth_has_account_link,
                      style: const TextStyle(color: Color(0xFF38BDF8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF38BDF8)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
