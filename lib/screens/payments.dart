import 'package:flutter/material.dart';
import 'package:navyoga_academy/Dashboard/dashboard_menu.dart';

/// ================= MODELS =================
class Subscription {
  final String planName;
  final String activeSince;
  final String price;
  final String nextBilling;
  final String billingCycle;
  final bool isActive;
  final List<String> features;

  Subscription({
    required this.planName,
    required this.activeSince,
    required this.price,
    required this.nextBilling,
    required this.billingCycle,
    required this.isActive,
    required this.features,
  });
}

class Plan {
  final String name;
  final String price;
  final String yearly;
  final Color color;
  final bool isPopular;
  final bool isCurrent;
  final IconData icon;
  final List<String> features;

  Plan({
    required this.name,
    required this.price,
    required this.yearly,
    required this.color,
    this.isPopular = false,
    this.isCurrent = false,
    required this.icon,
    required this.features,
  });
}

class PaymentMethod {
  final String brand;
  final String number;
  final String expiry;
  final bool isDefault;

  PaymentMethod({
    required this.brand,
    required this.number,
    required this.expiry,
    this.isDefault = false,
  });
}

class PaymentHistory {
  final String title;
  final String date;
  final String amount;

  PaymentHistory({
    required this.title,
    required this.date,
    required this.amount,
  });
}

/// ================= SERVICE =================
class SubscriptionService {
  Future<Subscription> fetchSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Subscription(
      planName: "Premium",
      activeSince: "Jan 10, 2026",
      price: "₹999",
      nextBilling: "May 10, 2026",
      billingCycle: "Monthly",
      isActive: true,
      features: [
        "Unlimited class access",
        "All recording sessions",
        "Priority booking",
        "Personal progress tracking",
        "Mobile app access",
      ],
    );
  }

  List<Plan> getPlans() => [
    Plan(
      name: "Basic",
      price: "₹499",
      yearly: "₹4990/year",
      color: Colors.green,
      icon: Icons.shield,
      features: [
        "10 classes per month",
        "Access to recordings",
        "Basic progress tracking",
        "Mobile app access",
        "Email support",
      ],
    ),
    Plan(
      name: "Premium",
      price: "₹999",
      yearly: "₹9990/year",
      color: Colors.deepOrange,
      isPopular: true,
      isCurrent: true,
      icon: Icons.flash_on,
      features: [
        "Unlimited class access",
        "All recording sessions",
        "Priority booking",
        "Personal progress tracking",
        "Mobile app access",
        "Live chat support",
        "Exclusive workshops",
      ],
    ),
    Plan(
      name: "Platinum",
      price: "₹1999",
      yearly: "₹19990/year",
      color: Colors.purple,
      icon: Icons.workspace_premium,
      features: [
        "Everything in Premium",
        "1-on-1 personal sessions",
        "Custom meal plans",
        "Dedicated instructor",
        "Home visit option",
        "Priority support 24/7",
        "Exclusive VIP events",
        "Free merchandise",
      ],
    ),
  ];

  List<PaymentMethod> getPaymentMethods() => [
    PaymentMethod(
      brand: "Visa",
      number: "•••• 1234",
      expiry: "12/28",
      isDefault: true,
    ),
    PaymentMethod(brand: "Mastercard", number: "•••• 5678", expiry: "09/27"),
  ];

  List<PaymentHistory> getPayments() => [
    PaymentHistory(
      title: "Premium Monthly",
      date: "Apr 10, 2026",
      amount: "₹999",
    ),
    PaymentHistory(
      title: "Premium Monthly",
      date: "Mar 10, 2026",
      amount: "₹999",
    ),
    PaymentHistory(
      title: "Premium Monthly",
      date: "Feb 10, 2026",
      amount: "₹999",
    ),
  ];
}

/// ================= MAIN SCREEN =================
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
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black54),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "NavYoga Academy",
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),

      body: FutureBuilder<Subscription>(
        future: future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sub = snap.data!;
          final plans = service.getPlans();
          final cards = service.getPaymentMethods();
          final payments = service.getPayments();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerBanner(),

                const SizedBox(height: 20),

                /// ================= SUBSCRIPTION =================
                subscriptionCard(sub),

                const SizedBox(height: 25),

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

                chip("Save 17% with yearly plans"),

                const SizedBox(height: 15),

                ...plans.map((p) => planCard(p)),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ✅ HEADER INSIDE CONTAINER
                      sectionHeader("Payment Methods", "+ Add Card"),

                      const SizedBox(height: 12),

                      /// CARDS
                      ...cards.map((c) => paymentCard(c)).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.deepOrange.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // /// ✅ HEADER INSIDE
                      sectionHeader("Recent Payments", "Download All"),
                      const SizedBox(height: 12),

                      /// ✅ CARDS
                      ...payments.map((p) => paymentHistoryCard(p)).toList(),

                      const SizedBox(height: 12),

                      /// ✅ BUTTON INSIDE
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "View All Payment History",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget headerBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Payments &\nSubscription",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Manage your subscription plans and\npayment methods",
          style: TextStyle(fontSize: 14, color: Colors.blueGrey),
        ),
      ],
    );
  }

  /// ================= UI =================
  Widget subscriptionCard(Subscription sub) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepOrange, width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Plan: ${sub.planName}",
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Active since ${sub.activeSince}",
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ],
              ),

              /// ACTIVE CHIP (updated)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Active",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// INFO BOXES
          infoBox("Monthly Price", sub.price, const Color(0xfff3e6df)),
          infoBox(
            "Next Billing Date",
            sub.nextBilling,
            const Color(0xffebe7f2),
          ),
          infoBox("Billing Cycle", sub.billingCycle, const Color(0xffe3efea)),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 1,
            color: Colors.deepOrange.withValues(alpha: 0.2),
          ),

          const SizedBox(height: 10),

          const Text(
            "Plan Features",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          ...sub.features.map((f) => feature(f)),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(child: outlineButton("Change Billing Cycle")),
              const SizedBox(width: 10),
              Expanded(child: outlineButton("Cancel Subscription", red: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget planCard(Plan p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: p.isPopular
              ? Colors.deepOrange
              : Colors.deepOrange.withOpacity(0.2),
          width: p.isPopular ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW (with badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(p.icon, color: p.color),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    p.name,
                    style: TextStyle(
                      color: p.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              /// 🔥 MOST POPULAR BADGE
              if (p.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Most Popular",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          /// PRICE
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: p.price,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(
                  text: "/month",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "or ${p.yearly}",
            style: const TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 16),

          /// FEATURES
          ...p.features.map((f) => feature(f, color: p.color)),

          const SizedBox(height: 20),

          /// BUTTON (CURRENT PLAN STYLE FIXED)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: p.isCurrent ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: p.isCurrent ? Colors.grey.shade400 : p.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                p.isCurrent ? "Current Plan" : "Upgrade Now",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentCard(PaymentMethod m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card, color: Colors.deepPurple),
          ),

          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${m.brand} ${m.number}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Expires ${m.expiry}",
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          /// RIGHT SIDE
          Column(
            children: [
              if (m.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Default"),
                ),

              const SizedBox(height: 8),

              const Icon(Icons.close, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget paymentHistoryCard(PaymentHistory p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(p.date, style: const TextStyle(color: Colors.blueGrey)),
            ],
          ),

          /// RIGHT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                p.amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Paid",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= SMALL WIDGETS =================

  Widget feature(String text, {Color color = Colors.green}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    ),
  );

  Widget infoBox(String t, String v, Color c) => Container(
    width: double.infinity, // 🔥 makes it full width (IMPORTANT)
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
        const SizedBox(height: 6),
        Text(
          v,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  Widget iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color),
  );

  Widget chip(
    String text, {
    Color color = const Color.fromARGB(255, 7, 7, 7),
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(color: color)),
  );

  Widget sectionHeader(String t, String action) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        t,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
      ),

      /// 🔥 PAYMENT METHODS BUTTON (FIX)
      if (t == "Payment Methods")
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text("Add Card", style: TextStyle(color: Colors.white)),
        )
      /// 🔽 RECENT PAYMENTS BUTTON (already correct)
      else if (t == "Recent Payments")
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          icon: const Icon(Icons.download, size: 16, color: Colors.black54),
          label: const Text(
            "Download All",
            style: TextStyle(color: Colors.black54),
          ),
        )
      /// 🔽 DEFAULT (for other sections)
      else
        chip(action),
    ],
  );

  Widget outlineButton(String t, {bool red = false}) => OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: red ? Colors.red : Colors.deepOrange),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: Text(
      t,
      style: TextStyle(color: red ? Colors.red : Colors.deepOrange),
    ),
  );
}
