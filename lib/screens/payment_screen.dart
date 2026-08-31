import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/services/payment_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final paymentService = PaymentService();
  Future<void> startPayment(BuildContext context, Plan plan) async {
    final token = await AuthManager.getToken();

    if (token == null) return;

    final response = await paymentService.initiatePayment(token, {
      "type": "SELF_PACED",
      "planId": plan.id,
    });

    print("INITIATE RESPONSE => $response");

    if (response["success"] != true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Unable to initiate payment"),
        ),
      );

      return;
    }

    final data = response["data"];

    var options = {
      "key": data["key"],
      "amount": data["amount"],
      "order_id": data["orderId"],
      "name": "NavYoga Academy",
      "description": plan.name,
      "currency": data["currency"],
    };

    _razorpay.open(options);
  }

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final verifyResponse = await paymentService.verifyPayment(token, {
        "razorpayOrderId": response.orderId,
        "razorpayPaymentId": response.paymentId,
        "razorpaySignature": response.signature,
      });

      print("VERIFY RESPONSE => $verifyResponse");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment Successful")));

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("PAYMENT FAILED => ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL WALLET => ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    final Plan plan = ModalRoute.of(context)!.settings.arguments as Plan;

    return Scaffold(

      drawer: const CustomDrawer(currentPage: "Payments"),


      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "₹${plan.price}",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Plan Features",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...plan.features.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e)),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await startPayment(context, plan);
                },
                child: const Text("Pay Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
