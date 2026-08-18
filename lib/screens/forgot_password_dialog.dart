import 'package:flutter/material.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/utils/api_helper.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  int _step = 0;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _accessToken;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (phone.length < 8 || phone.length > 15) {
      setState(() => _error = 'Enter 8–15 digits including country code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      dynamic response;
      if (_step == 0) {
        response = await _authService.sendPasswordResetOtp(phone: phone);
      } else if (_step == 1) {
        final code = _otpController.text.trim();
        if (!RegExp(r'^\d{4,6}$').hasMatch(code)) {
          throw const FormatException('Enter the OTP sent on WhatsApp.');
        }
        response = await _authService.verifyPasswordResetOtp(
          phone: phone,
          code: code,
        );
      } else {
        final password = _passwordController.text;
        if (password.length < 8) {
          throw const FormatException('Password must be at least 8 characters.');
        }
        response = await _authService.resetPassword(
          phone: phone,
          accessToken: _accessToken!,
          newPassword: password,
        );
      }

      if (!ApiHelper.isSuccess(response)) {
        throw Exception(ApiHelper.getMessage(response));
      }

      if (!mounted) return;
      if (_step == 0) {
        setState(() => _step = 1);
      } else if (_step == 1) {
        final rawData = response['data'];
        _accessToken = rawData is Map
            ? rawData['accessToken']?.toString()
            : response['accessToken']?.toString();
        _accessToken ??= response['accessToken']?.toString();
        if (_accessToken == null || _accessToken!.isEmpty) {
          throw const FormatException('OTP verified without a reset token.');
        }
        setState(() => _step = 2);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('FormatException: ', '');
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Reset password', 'Verify WhatsApp OTP', 'New password'];
    return AlertDialog(
      title: Text(titles[_step]),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 0)
              TextField(
                controller: _phoneController,
                autofocus: true,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Registered phone number',
                  hintText: '919876543210',
                  helperText: 'Include country code without +',
                ),
              )
            else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text('WhatsApp: +${_phoneController.text}'),
              ),
              const SizedBox(height: 12),
              if (_step == 1)
                TextField(
                  controller: _otpController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'OTP'),
                )
              else
                TextField(
                  controller: _passwordController,
                  autofocus: true,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _continue,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_step == 2 ? 'Reset password' : 'Continue'),
        ),
      ],
    );
  }
}
