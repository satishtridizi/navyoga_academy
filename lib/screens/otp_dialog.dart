import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPDialog extends StatefulWidget {
  final String phone;
  final bool isLoading;

  /// Returns the complete OTP entered by the user.
  final ValueChanged<String> onVerify;

  final VoidCallback onResend;
  final VoidCallback? onEditPhone;

  const OTPDialog({
    super.key,
    required this.phone,
    required this.onVerify,
    required this.onResend,
    this.onEditPhone,
    this.isLoading = false,
  });

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  String get enteredOtp {
    return controllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() {
    final otp = enteredOtp.trim();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the complete 4-digit OTP."),
        ),
      );
      return;
    }

    widget.onVerify(otp);
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(22, 42, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Verify your phone number",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xff6B7280),
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text: "We sent a 4-digit code via SMS to ",
                        ),
                        TextSpan(
                          text: widget.phone,
                          style: const TextStyle(
                            color: Color(0xff6A1B9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ". Enter it below to continue.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 46,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: index == 3
                              ? TextInputAction.done
                              : TextInputAction.next,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: const Color(0xffF4F5FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              focusNodes[index + 1].requestFocus();
                            }

                            if (value.isEmpty && index > 0) {
                              focusNodes[index - 1].requestFocus();
                            }

                            if (enteredOtp.length == 4) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          onSubmitted: (_) {
                            if (index == 3) {
                              _verifyOtp();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: widget.isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xffFFB089),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.isLoading ? null : widget.onResend,
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: Color(0xffA77AD8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: widget.onEditPhone,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xff6B7280),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Wrong number? Edit phone",
                            style: TextStyle(
                              color: Color(0xff6B7280),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF8A65),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_outlined,
                    color: Colors.white,
                    size: 26,
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