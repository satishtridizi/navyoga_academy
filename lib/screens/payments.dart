import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/payment_data.dart';
import 'package:navyoga_academy/models/currentSubscription.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/routes/app_routes.dart';
import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';
import 'package:navyoga_academy/widgets/payment_method_card.dart';
import 'package:navyoga_academy/widgets/payments_header_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  double originalPrice = 1000; // example
  double finalPrice = 1000;

  String appliedCoupon = "";
  double discountPercent = 0;

  // 🔥 ADD HERE
  void applyCoupon(Map couponData) {
    setState(() {
      appliedCoupon = couponData["code"];
      discountPercent = couponData["discount"];

      finalPrice = originalPrice - (originalPrice * discountPercent / 100);
    });
  }

  List<PaymentHistory> payments = [];
  CurrentSubscription? currentPlan;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final plans = service.getPlans();

    return AppScaffold(
      currentIndex: null,
      drawer: const CustomDrawer(currentPage: "Payments"),

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
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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

            const Text(
              "Upgrade Your Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                // final result = await Navigator.pushNamed(
                //   context,
                //   AppRoutes.coupons,
                // );

                // if (result != null) {
                //   applyCoupon(result as Map);
                // }
              },
              child: const Text("Apply Coupon"),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Save 17% with yearly plans"),
            ),

            const SizedBox(height: 20),

            // ...plans.asMap().entries.map((entry) {
            //   final index = entry.key;
            //   final p = entry.value;

            //   return Animate(
            //     delay: Duration(milliseconds: 150 * index),

            //     effects: const [
            //       FadeEffect(duration: Duration(milliseconds: 500)),
            //       SlideEffect(
            //         begin: Offset(0, 0.15),
            //         end: Offset(0, 0),
            //         duration: Duration(milliseconds: 500),
            //       ),
            //     ],

            //     child: GestureDetector(
            //       onTap: () {
            //         setState(() {
            //           originalPrice = double.parse(p.price.toString());
            //           finalPrice = double.parse(p.price.toString());

            //           appliedCoupon = "";
            //           discountPercent = 0;
            //         });
            //       },
            //       child: PlanCard(
            //         plan: Plan(
            //           color: Colors.orange,
            //           yearly: "",
            //           name: p.name,
            //           icon: Icons.workspace_premium,
            //           price: p.price,
            //           isPopular: p.isActive,
            //           features: [],
            //         ),
            //         currentPlanName: "",
            //       ),
            //     ),
            //   );
            // }),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Original Price: ₹$originalPrice"),

                if (discountPercent > 0) Text("Discount: $discountPercent%"),

                const SizedBox(height: 8),

                Text(
                  "Final Price: ₹$finalPrice",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
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
                          onPressed: () {
                            AppSnackbar.showWarning(
                              context,

                              "Add card feature coming soon",
                            );
                          },
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
                          FadeEffect(duration: Duration(milliseconds: 400)),

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
                  border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    /// HEADER
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Recent Payments (0)",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Download"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// LIST
                    /// EMPTY STATE
                    if (payments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "No payment history available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    /// LIST
                    ...payments.asMap().entries.map((entry) {
                      final index = entry.key;
                      final p = entry.value;

                      return Animate(
                        delay: Duration(milliseconds: 120 * index),

                        effects: const [
                          FadeEffect(duration: Duration(milliseconds: 400)),

                          SlideEffect(
                            begin: Offset(0.2, 0),
                            end: Offset(0, 0),
                            duration: Duration(milliseconds: 400),
                          ),
                        ],

                        child: paymentHistoryCard(
                          PaymentHistory(
                            title: p.title,
                            amount: p.amount,
                            date: p.date,
                          ),
                        ),
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
                                payments: payments.map((p) {
                                  return PaymentHistory(
                                    title: p.title,
                                    amount: p.amount,
                                    date: p.date,
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            214,
                            214,
                            214,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "View All Payment History",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
