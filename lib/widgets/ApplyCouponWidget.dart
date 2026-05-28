import 'package:flutter/material.dart';
import '../services/coupon_service.dart';
import '../utils/auth_manager.dart';

class ApplyCouponWidget extends StatefulWidget {
  final String paymentType;
  final String? planId;
  final String? courseId;
  final String? batchId;
  final String? entityId;

  const ApplyCouponWidget({
    super.key,
    required this.paymentType,
    this.planId,
    this.courseId,
    this.batchId,
    this.entityId,
  });

  @override
  State<ApplyCouponWidget> createState() => _ApplyCouponWidgetState();
}

class _ApplyCouponWidgetState extends State<ApplyCouponWidget> {
  final TextEditingController couponController = TextEditingController();

  final CouponService service = CouponService();

  bool isLoading = false;

  String message = "";

  double discountAmount = 0;

  double finalAmount = 0;

  Future<void> applyCoupon() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    if (couponController.text.trim().isEmpty) {
      setState(() {
        message = "Enter coupon code";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    final res = await service.validateCoupon(
      couponCode: couponController.text.trim(),
      token: token,
      type: widget.paymentType,
      planId: widget.planId,
      courseId: widget.courseId,
      batchId: widget.batchId,
      entityId: widget.entityId,
    );

    setState(() {
      isLoading = false;
    });

    if (res["success"] == true) {
      final data = res["data"];

      setState(() {
        discountAmount = (data["discountAmount"] ?? 0).toDouble();

        finalAmount = (data["finalAmount"] ?? 0).toDouble();

        message = "Coupon applied successfully";
      });
    } else {
      setState(() {
        message = res["message"] ?? "Invalid coupon";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: couponController,
          decoration: const InputDecoration(hintText: "Enter coupon code"),
        ),

        const SizedBox(height: 10),

        ElevatedButton(
          onPressed: isLoading ? null : applyCoupon,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Apply Coupon"),
        ),

        const SizedBox(height: 10),

        if (message.isNotEmpty) Text(message),

        if (discountAmount > 0) Text("Discount: ₹$discountAmount"),

        if (finalAmount > 0) Text("Final Amount: ₹$finalAmount"),
      ],
    );
  }
}
