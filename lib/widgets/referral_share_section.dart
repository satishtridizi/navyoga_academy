import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareSection extends StatelessWidget {
  final String referralCode;
  final String referralLink;

  const ShareSection({
    super.key,
    required this.referralCode,
    required this.referralLink,
  });

  Widget _socialButton(
    BuildContext context,
    String text,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(.9), color]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffF2DED2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share Your Referral Code",
            style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Share your unique code with friends and family",
            style: TextStyle(color: Colors.blueGrey),
          ),

          const SizedBox(height: 16),

          /// CODE
          const Text("Your Referral Code"),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(referralCode),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  final code = referralCode;

                  Clipboard.setData(ClipboardData(text: code));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Referral code copied 🎉")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Copy", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// LINK
          const Text("Your Referral Link"),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(referralLink, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  final link = referralLink;
                  Clipboard.setData(ClipboardData(text: link));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Referral link copied ✅")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Copy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text("Share on Social Media"),

          const SizedBox(height: 10),

          Row(
            children: [
              _socialButton(
                context,
                "WhatsApp",
                Colors.green,
                Icons.chat,
                () async {
                  final url = Uri.parse(
                    "https://wa.me/?text=Join NavYoga using my referral code $referralCode $referralLink",
                  );
                  await launchUrl(url);
                },
              ),
              const SizedBox(width: 10),
              _socialButton(context, "Email", Colors.blue, Icons.email, () async {
                final url = Uri.parse(
                  "mailto:?subject=Join NavYoga&body=Use my referral code $referralCode $referralLink",
                );
                await launchUrl(url);
              }),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _socialButton(
                context,
                "Facebook",
                Colors.blueAccent,
                Icons.facebook,
                () async {
                  final url = Uri.parse(
                    "https://www.facebook.com/sharer/sharer.php?u=$referralLink",
                  );
                  await launchUrl(url);
                },
              ),
              const SizedBox(width: 10),
              _socialButton(
                context,
                "Twitter",
                Colors.lightBlue,
                Icons.flutter_dash,
                () async {
                  final url = Uri.parse(
                    "https://twitter.com/intent/tweet?text=Join NavYoga using my referral code $referralCode $referralLink",
                  );
                  await launchUrl(url);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
