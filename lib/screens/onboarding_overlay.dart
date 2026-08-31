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

 String? otpRequestId;

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
  if (phone.trim().isEmpty) {
    setState(() {
      error = "Phone number is not available.";
    });
    return;
  }

  setState(() {
    loading = true;
    error = null;
  });

  try {
    final normalizedPhone = phone
        .replaceAll("+91", "")
        .replaceAll(" ", "")
        .trim();

    final response = await _msg91.sendOtp("91$normalizedPhone");

    debugPrint("MSG91 SEND OTP RESPONSE = $response");

    if (response == null) {
      throw Exception("No response received while sending OTP.");
    }


    final dynamic requestId =
        response["reqId"] ??
        response["requestId"] ??
        response["data"]?["reqId"] ??
        response["data"]?["requestId"];

    if (requestId == null || requestId.toString().trim().isEmpty) {
      final message =
          response["message"]?.toString() ??
          "OTP request ID was not received.";

      throw Exception(message);
    }

    otpRequestId = requestId.toString();

    if (!mounted) return;

    setState(() {
      currentStep = 2;
    });

    _showMessage(
      "OTP has been sent successfully to +91 $normalizedPhone.",
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = _cleanError(e);
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
Future<void> _verifyOtp(String otp) async {
  if (otpRequestId == null || otpRequestId!.isEmpty) {
    setState(() {
      error = "OTP request expired. Please resend the OTP.";
    });
    return;
  }

  if (otp.length != 4) {
    setState(() {
      error = "Please enter the complete 4-digit OTP.";
    });
    return;
  }

  setState(() {
    loading = true;
    error = null;
  });

  try {
    final response = await _msg91.verifyOtp(
      reqId: otpRequestId!,
      otp: otp,
    );

    debugPrint("MSG91 VERIFY OTP RESPONSE = $response");

    if (response == null) {
      throw Exception("No response received while verifying OTP.");
    }

    final responseType = response["type"]?.toString().toLowerCase();
    final responseMessage =
        response["message"]?.toString() ??
        response["data"]?["message"]?.toString() ??
        "";

    final bool isVerified =
        response["success"] == true ||
        response["verified"] == true ||
        responseType == "success" ||
        responseMessage.toLowerCase().contains("verified") ||
        responseMessage.toLowerCase().contains("success");

    if (!isVerified) {
      throw Exception(
        responseMessage.isNotEmpty
            ? responseMessage
            : "The OTP is invalid or expired.",
      );
    }

    if (!mounted) return;

    _showMessage("Phone number verified successfully.");

    widget.onFinished();
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = _cleanError(e);
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
Future<void> _resendOtp() async {
  if (otpRequestId == null || otpRequestId!.isEmpty) {
    await _sendOtp();
    return;
  }

  setState(() {
    loading = true;
    error = null;
  });

  try {
    final response = await _msg91.retryOtp(otpRequestId!);

    debugPrint("MSG91 RESEND OTP RESPONSE = $response");

    if (response == null) {
      throw Exception("No response received while resending OTP.");
    }

    final responseType = response["type"]?.toString().toLowerCase();
    final responseMessage =
        response["message"]?.toString() ??
        response["data"]?["message"]?.toString() ??
        "";

    final bool resendSuccessful =
        response["success"] == true ||
        responseType == "success" ||
        responseMessage.toLowerCase().contains("sent") ||
        responseMessage.toLowerCase().contains("success");

    if (!resendSuccessful) {
      throw Exception(
        responseMessage.isNotEmpty
            ? responseMessage
            : "Unable to resend OTP.",
      );
    }

    if (!mounted) return;

    _showMessage("A new OTP has been sent to your phone.");
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = _cleanError(e);
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
String _cleanError(Object error) {
  return error.toString().replaceFirst("Exception: ", "");
}

void _showMessage(String message) {
  if (!mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

 Widget _currentDialog() {
  switch (currentStep) {
    case 0:
      return TermsDialog(
        key: const ValueKey("terms_dialog"),
        onAccept: _acceptTerms,
      );

    case 1:
      return PhoneVerificationDialog(
        key: const ValueKey("phone_verification_dialog"),
        phone: phone.isEmpty ? "+91 **********" : "+91 $phone",
        onContinue: _sendOtp,
        isLoading: loading,
      );

    default:
      return OTPDialog(
        key: const ValueKey("otp_dialog"),
        phone: phone.isEmpty ? "+91 **********" : "+91 $phone",
        onEditPhone: () {
          setState(() {
            currentStep = 1;
            error = null;
            otpRequestId = null;
          });
        },
        onVerify: _verifyOtp,
        onResend: _resendOtp,
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
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 40,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: _currentDialog(),
          ),
        ),

        if (error != null && error!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEF9A9A),
              ),
            ),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    ),
  ),
),
        ],
      ),
    );
  }
}
