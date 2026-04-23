import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/payments_service.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';
import 'package:navyoga_academy/widgets/payment_method_card.dart';
import 'package:navyoga_academy/widgets/payments_header_banner.dart';
import 'package:navyoga_academy/widgets/payments_plan_card.dart';
import 'package:navyoga_academy/widgets/payments_subscription_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final service = SubscriptionService();
  late Future<Subscription> future;

  @override
  void initState() {
    future = service.fetchSubscription();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final plans = service.getPlans();
    final cards = service.getPaymentMethods();
    final payments = service.getPayments();

    return Scaffold(
      drawer: const CustomDrawer(),

      /// 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// 🔥 BODY
      body: FutureBuilder<Subscription>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sub = snap.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                HeaderBanner(),

                const SizedBox(height: 20),

                /// ================= CURRENT PLAN =================
                SubscriptionCard(sub: sub),

                const SizedBox(height: 16),

                /// ================= UPGRADE =================
                const Text(
                  "Upgrade Your Plan",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Save 17% with yearly plans"),
                ),

                const SizedBox(height: 20),

                ...plans.map((p) => PlanCard(plan: p)),

                const SizedBox(height: 25),

                /// ================= PAYMENT METHODS (FIXED) =================
                /// ================= PAYMENT METHODS =================
                /// ================= PAYMENT METHODS =================
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F4F6), // 🔥 light grey bg
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(
                        0.2,
                      ), // 🔥 subtle border
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Payment Methods",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add,
                              size: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            label: const Text(
                              "Add Card",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// CARDS
                      ...cards.map((c) => paymentCard(c)),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// ================= RECENT PAYMENTS =================
                /// ================= RECENT PAYMENTS =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      /// HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Payments",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),

                          /// 🔥 DOWNLOAD BUTTON
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.deepOrange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.download, size: 18),
                                SizedBox(width: 6),
                                Text("Download All"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// LIST
                      ...payments.map((p) => paymentHistoryCard(p)),

                      const SizedBox(height: 20),

                      /// BUTTON
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 230, 227, 227),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          "View All Payment History",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
