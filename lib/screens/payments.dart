import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/payment_data.dart';
import 'package:navyoga_academy/data/payments_service.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/widgets/app_background.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';
import 'package:navyoga_academy/widgets/payment_method_card.dart';
import 'package:navyoga_academy/widgets/payments_header_banner.dart';
import 'package:navyoga_academy/widgets/payments_plan_card.dart';
import 'package:navyoga_academy/widgets/payments_subscription_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    final payments = service.getPayments();

    return Scaffold(
      drawer: const CustomDrawer(),

      /// 🔥 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: AppBackground(
        child: FutureBuilder<Subscription>(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final sub = snap.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= HEADER =================
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 500)),
                      SlideEffect(
                        begin: Offset(0, 0.2),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 500),
                      ),
                    ],

                    child: HeaderBanner(),
                  ),

                  const SizedBox(height: 20),

                  /// ================= CURRENT PLAN =================
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),
                      SlideEffect(
                        begin: Offset(0, 0.15),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 600),
                      ),
                    ],

                    child: SubscriptionCard(sub: sub),
                  ),

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

                  ...plans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;

                    return Animate(
                      delay: Duration(milliseconds: 150 * index),

                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 500)),
                        SlideEffect(
                          begin: Offset(0, 0.15),
                          end: Offset(0, 0),
                          duration: Duration(milliseconds: 500),
                        ),
                      ],

                      child: PlanCard(plan: p, currentPlanName: sub.planName),
                    );
                  }),

                  const SizedBox(height: 25),

                  /// ================= PAYMENT METHODS =================
                  /// ================= PAYMENT METHODS =================
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),

                      SlideEffect(
                        begin: Offset(0, 0.2),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 600),
                      ),
                    ],

                    child: Container(
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
                          ...PaymentData.methods.asMap().entries.map((entry) {
                            final index = entry.key;
                            final c = entry.value;

                            return Animate(
                              delay: Duration(milliseconds: 120 * index),

                              effects: const [
                                FadeEffect(
                                  duration: Duration(milliseconds: 400),
                                ),

                                SlideEffect(
                                  begin: Offset(0.2, 0),
                                  end: Offset(0, 0),
                                  duration: Duration(milliseconds: 400),
                                ),
                              ],

                              child: paymentCard(c),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ================= RECENT PAYMENTS =================
                  Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),

                      SlideEffect(
                        begin: Offset(0, 0.2),
                        end: Offset(0, 0),
                        duration: Duration(milliseconds: 600),
                      ),
                    ],

                    child: Container(
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
                              OutlinedButton.icon(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text("Download All"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// LIST
                          ...payments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final p = entry.value;

                            return Animate(
                              delay: Duration(milliseconds: 120 * index),

                              effects: const [
                                FadeEffect(
                                  duration: Duration(milliseconds: 400),
                                ),

                                SlideEffect(
                                  begin: Offset(0.2, 0),
                                  end: Offset(0, 0),
                                  duration: Duration(milliseconds: 400),
                                ),
                              ],

                              child: paymentHistoryCard(p),
                            );
                          }),

                          const SizedBox(height: 20),

                          /// BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentHistoryScreen(
                                      payments: payments,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                "View All Payment History",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
