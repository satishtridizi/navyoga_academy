import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';
import 'package:navyoga_academy/data/payment_data.dart';
import 'package:navyoga_academy/models/currentSubscription.dart';
import 'package:navyoga_academy/models/payments_models.dart';
import 'package:navyoga_academy/widgets/plan_card.dart';
import 'package:navyoga_academy/screens/payment_history_screen.dart';
import 'package:navyoga_academy/widgets/app_scaffold.dart';
import 'package:navyoga_academy/widgets/payment_history_card.dart';
import 'package:navyoga_academy/widgets/payment_method_card.dart';
import 'package:navyoga_academy/widgets/payments_header_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navyoga_academy/utils/app_snackbar.dart';
import 'package:navyoga_academy/services/subscription_service.dart';
import 'package:navyoga_academy/utils/auth_manager.dart';
import 'package:intl/intl.dart';

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

  double getPlanPrice(String planName) {
    switch (planName.toLowerCase()) {
      case "monthly":
        return 399;

      case "quarterly":
        return 999;

      case "half-yearly":
        return 1499;

      case "yearly":
        return 2499;

      default:
        return 0;
    }
  }

  List<PaymentMethod> paymentMethods = [];

  String getBillingCycle(String planName) {
    switch (planName.toLowerCase()) {
      case "monthly":
        return "Monthly";

      case "quarterly":
        return "Quarterly";

      case "half-yearly":
        return "Half-Yearly";

      case "yearly":
        return "Yearly";

      default:
        return "Monthly";
    }
  }

  List<String> getPlanFeatures(String planName) {
    switch (planName.toLowerCase()) {
      case "monthly":
        return [
          "Access to recorded classes",
          "Learn at your own pace",
          "Lifetime access to content",
          "Progress tracking",
          "Mobile & web access",
        ];

      case "quarterly":
        return [
          "All Monthly features",
          "3 months commitment",
          "Better value (17% off)",
          "Extended content library",
          "Priority support",
          "Downloadable resources",
        ];

      case "half-yearly":
        return [
          "All Quarterly features",
          "6 months commitment",
          "Advanced content access",
          "Personalized guidance",
          "Certificate of completion",
        ];

      case "yearly":
        return [
          "All Half-Yearly features",
          "12 months commitment",
          "Complete library access",
          "Expert consultation",
        ];

      default:
        return [];
    }
  }

  void applyCoupon(Map couponData) {
    setState(() {
      appliedCoupon = couponData["code"];
      discountPercent = couponData["discount"];

      finalPrice = originalPrice - (originalPrice * discountPercent / 100);
    });
  }

  String formatDate(String date) {
    return DateFormat("MMM d, yyyy").format(DateTime.parse(date));
  }

  Future<void> loadPlans() async {
    try {
      final token = await AuthManager.getToken();

      if (token == null) return;

      final plansResponse = await subscriptionService.getPlans(token);
      print("PLANS RESPONSE => $plansResponse");
      final subscriptionResponse = await subscriptionService.getMySubscription(
        token,
      );

      final List plansData = plansResponse["data"] ?? [];
      print("SUBSCRIPTION RESPONSE => $subscriptionResponse");

      plans = plansData.map((e) {
        return Plan(
          id: e["id"] ?? "",
          name: e["name"] ?? "",
          price: e["price"].toString(),
          yearly: (e["originalPrice"] ?? e["price"]).toString(),
          color: Colors.deepOrange,
          icon: Icons.workspace_premium_outlined,
          features: List<String>.from(e["features"] ?? []),
          isPopular: (e["name"] ?? "").toLowerCase() == "premium",
        );
      }).toList();

      if (subscriptionResponse["data"]["enrolled"] == true) {
        final sub = subscriptionResponse["data"]["subscription"];

        final planName = sub["planName"] ?? "";

        currentPlan = CurrentSubscription(
          name: planName,
          status: "ACTIVE",
          monthlyPrice: getPlanPrice(planName),
          billingCycle: getBillingCycle(planName),
          nextBillingDate: sub["expiresAt"] ?? "",
          activeSince: sub["startDate"] ?? "",
          features: getPlanFeatures(planName),
        );
        print("CURRENT PLAN => $currentPlan");
      }

      setState(() {});
    } catch (e) {
      debugPrint("LOAD PLAN ERROR => $e");
    }
  }

  List<PaymentHistory> payments = [];
  CurrentSubscription? currentPlan;

  List<Plan> plans = [];

  final subscriptionService = SubscriptionService();

  void loadPaymentMethods() {
    paymentMethods = [
      PaymentMethod(
        brand: "Visa",
        number: "•••• 4242",
        expiry: "12/26",
        isDefault: true,
      ),

      PaymentMethod(brand: "Mastercard", number: "•••• 5678", expiry: "08/25"),

      PaymentMethod(brand: "RuPay", number: "•••• 1122", expiry: "03/27"),
    ];
  }

  @override
  void initState() {
    super.initState();
    loadPlans();
    loadPaymentMethods();
  }

  Widget _infoBox(String title, String value, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff20203A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final plans = service.getPlans();

    return AppScaffold(
      currentIndex: null,
      drawer: const CustomDrawer(currentPage: "Subscription"),

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
        title: Image.asset(
          'assets/logo/logo_transparent_clean.png',
          height: 60,
        ),
        centerTitle: true,
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
            if (currentPlan != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.deepOrange.withOpacity(.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.deepOrange,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.deepOrange,
                                  ),
                                  children: [
                                    const TextSpan(text: "Current Plan: "),
                                    TextSpan(text: currentPlan!.name),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Active since ${formatDate(currentPlan!.activeSince)}",
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "Active",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Column(
                      children: [
                        _infoBox(
                          "Monthly Price",
                          "₹${currentPlan!.monthlyPrice.toInt()}",
                          const Color(0xffF8F1ED),
                        ),

                        const SizedBox(height: 14),

                        _infoBox(
                          "Next Billing Date",
                          formatDate(currentPlan!.nextBillingDate),
                          const Color(0xffF4EFF8),
                        ),

                        const SizedBox(height: 14),

                        _infoBox(
                          "Billing Cycle",
                          currentPlan!.billingCycle,
                          const Color(0xffEEF7F4),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 12),

                    const Text(
                      "Plan Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...currentPlan!.features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(feature)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              "Change Billing Cycle",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text(
                              "Cancel Subscription",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Text(
              "Upgrade Your Plan",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("Save 17% with yearly plans"),
            ),
            ...plans.map((plan) {
              return PlanCard(
                plan: plan,
                currentPlanName: currentPlan?.name ?? "",
                onUpgrade: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    "/payment",
                    arguments: plan,
                  );

                  if (result == true) {
                    await loadPlans();
                  }

                  if (result == true) {
                    await loadPlans();
                  }

                  setState(() {
                    originalPrice = double.tryParse(plan.price) ?? 0;
                    finalPrice = originalPrice;
                  });
                },
              );
            }).toList(),

            // const SizedBox(height: 20),

            // Animate(
            //   effects: const [
            //     FadeEffect(duration: Duration(milliseconds: 600)),

            //     SlideEffect(
            //       begin: Offset(0, 0.2),
            //       end: Offset(0, 0),
            //       duration: Duration(milliseconds: 600),
            //     ),
            //   ],

            //   child: Container(
            //     padding: const EdgeInsets.all(16),
            //     margin: const EdgeInsets.only(bottom: 20),
            //     decoration: BoxDecoration(
            //       color: const Color(0xffF3F4F6), // 🔥 light grey bg
            //       borderRadius: BorderRadius.circular(24),
            //       border: Border.all(
            //         color: Colors.deepOrange.withOpacity(
            //           0.2,
            //         ), // 🔥 subtle border
            //       ),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         /// HEADER
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             const Text(
            //               "Payment Methods",
            //               style: TextStyle(
            //                 fontSize: 22,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.deepOrange,
            //               ),
            //             ),

            //             ElevatedButton.icon(
            //               onPressed: () {
            //                 setState(() {
            //                   paymentMethods.add(
            //                     PaymentMethod(
            //                       brand: "Visa",
            //                       number: "9999",
            //                       expiry: "12/30",
            //                     ),
            //                   );
            //                 });
            //               },
            //               icon: const Icon(
            //                 Icons.add,
            //                 size: 19,
            //                 color: Colors.white,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //               label: const Text(
            //                 "Add Card",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               style: ElevatedButton.styleFrom(
            //                 backgroundColor: Colors.purple,
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(30),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),

            //         const SizedBox(height: 16),

            //         /// CARDS
            //         ...paymentMethods.asMap().entries.map((entry) {
            //           final index = entry.key;
            //           final c = entry.value;

            //           return Animate(
            //             delay: Duration(milliseconds: 120 * index),

            //             effects: const [
            //               FadeEffect(duration: Duration(milliseconds: 400)),

            //               SlideEffect(
            //                 begin: Offset(0.2, 0),
            //                 end: Offset(0, 0),
            //                 duration: Duration(milliseconds: 400),
            //               ),
            //             ],

            //             child: paymentCard(
            //               c,
            //               onDelete: () {
            //                 setState(() {
            //                   paymentMethods.removeAt(index);
            //                 });
            //               },
            //             ),
            //           );
            //         }).toList(),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 28),

            // /// ================= RECENT PAYMENTS =================
            // Animate(
            //   effects: const [
            //     FadeEffect(duration: Duration(milliseconds: 600)),

            //     SlideEffect(
            //       begin: Offset(0, 0.2),
            //       end: Offset(0, 0),
            //       duration: Duration(milliseconds: 600),
            //     ),
            //   ],

            //   child: Container(
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: const Color.fromARGB(255, 255, 255, 255),
            //       borderRadius: BorderRadius.circular(24),
            //       border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         /// HEADER
            //         /// HEADER
            //         Row(
            //           children: [
            //             Expanded(
            //               child: Text(
            //                 "Recent Payments (0)",
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ),
            //             const SizedBox(width: 10),
            //             ElevatedButton(
            //               onPressed: () {},
            //               child: const Text("Download"),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 16),

            //         /// LIST
            //         /// EMPTY STATE
            //         if (payments.isEmpty)
            //           const Padding(
            //             padding: EdgeInsets.all(16),
            //             child: Text(
            //               "No payment history available",
            //               style: TextStyle(color: Colors.grey),
            //             ),
            //           ),

            //         /// LIST
            //         ...payments.asMap().entries.map((entry) {
            //           final index = entry.key;
            //           final p = entry.value;

            //           return Animate(
            //             delay: Duration(milliseconds: 120 * index),

            //             effects: const [
            //               FadeEffect(duration: Duration(milliseconds: 400)),

            //               SlideEffect(
            //                 begin: Offset(0.2, 0),
            //                 end: Offset(0, 0),
            //                 duration: Duration(milliseconds: 400),
            //               ),
            //             ],

            //             child: paymentHistoryCard(
            //               PaymentHistory(
            //                 title: p.title,
            //                 amount: p.amount,
            //                 date: p.date,
            //               ),
            //             ),
            //           );
            //         }),

            //         const SizedBox(height: 20),

            //         /// BUTTON
            //         SizedBox(
            //           width: double.infinity,
            //           child: ElevatedButton(
            //             onPressed: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (_) => PaymentHistoryScreen(
            //                     payments: payments.map((p) {
            //                       return PaymentHistory(
            //                         title: p.title,
            //                         amount: p.amount,
            //                         date: p.date,
            //                       );
            //                     }).toList(),
            //                   ),
            //                 ),
            //               );
            //             },
            //             style: ElevatedButton.styleFrom(
            //               backgroundColor: const Color.fromARGB(
            //                 255,
            //                 214,
            //                 214,
            //                 214,
            //               ),
            //               padding: const EdgeInsets.symmetric(vertical: 16),
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(30),
            //               ),
            //             ),
            //             child: const Text(
            //               "View All Payment History",
            //               style: TextStyle(color: Colors.black),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
