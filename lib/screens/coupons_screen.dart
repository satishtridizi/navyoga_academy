import 'package:flutter/material.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final service = CouponService();

  List<CouponModel> coupons = [];
  bool isLoading = true;

  String appliedCoupon = "";

  @override
  void initState() {
    super.initState();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final res = await service.getCoupons(token);

    if (res["success"] == true) {
      final list = res["data"] as List;

      setState(() {
        coupons = list.map((e) => CouponModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void applyCoupon(CouponModel coupon) {
    if (!coupon.isActive) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Coupon expired ❌")));
      return;
    }

    // ✅ SEND BACK TO PAYMENT SCREEN
    Navigator.pop(context, {"code": coupon.code, "discount": coupon.discount});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Coupons")),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : coupons.isEmpty
          ? const Center(child: Text("No coupons available"))
          : ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (_, i) {
                final c = coupons[i];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(c.code),
                    subtitle: Text("${c.discount}% OFF"),
                    trailing: ElevatedButton(
                      onPressed: c.isActive ? () => applyCoupon(c) : null,
                      child: const Text("Apply"),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
