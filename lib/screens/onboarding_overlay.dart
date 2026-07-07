import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:navyoga_academy/services/auth_service.dart';
import 'package:navyoga_academy/services/msg91_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';

import 'otp_dialog.dart';
import 'phone_verification_dialog.dart';
import 'terms_dialog.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingOverlay({super.key, required this.onFinished});

  @override
  State<OnboardingOverlay> createState() => OnboardingOverlayState();
}

class OnboardingOverlayState extends State<OnboardingOverlay> {
  final AuthService _authService = AuthService();
  final Msg91Service _msg91 = Msg91Service();

  final TextEditingController otpController = TextEditingController();

  int currentStep = 0;

  bool loading = false;

  String? error;

  String phone = "";

  dynamic otpResponse;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final profile = await _authService.getProfile(token);

    if (profile["success"] == true) {
      phone = profile["data"]["phone"] ?? "";
      setState(() {});
    }
  }

  Future<void> _acceptTerms() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = await AuthManager.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      final res = await _authService.acceptTerms(token: token);

      if (res["success"] == true) {
        setState(() {
          currentStep = 1;
        });
      } else {
        error = res["message"];
      }
    } catch (e) {
      error = e.toString();
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      otpResponse = await _msg91.sendOtp("91$phone");

      debugPrint("MSG91 SEND OTP = $otpResponse");

      setState(() {
        currentStep = 2;
      });
    } catch (e) {
      error = e.toString();
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      debugPrint("OTP = ${otpController.text}");

      /// We will replace this after checking MSG91 response.
      widget.onFinished();
    } catch (e) {
      error = e.toString();
    }

    setState(() {
      loading = false;
    });
  }

  Widget _currentDialog() {
    switch (currentStep) {
      case 0:
        return TermsDialog(onAccept: _acceptTerms);

      case 1:
        return PhoneVerificationDialog(
          phone: phone.isEmpty ? "+91 **********" : "+91 $phone",
          onContinue: _sendOtp,
        );

      default:
        return OTPDialog(
          phone: phone.isEmpty ? "+91 **********" : "+91 $phone",
          key: ValueKey("otp_dialog"),
          onEditPhone: () {
            setState(() {
              currentStep = 1;
            });
          },

          onVerify: _verifyOtp,
          onResend: _sendOtp,
          isLoading: loading,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(.35)),
          ),
          Center(
            child: SingleChildScrollView(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _currentDialog(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
