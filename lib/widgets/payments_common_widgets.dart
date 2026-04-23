import 'package:flutter/material.dart';

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
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
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

Widget chip(String text, {Color color = const Color.fromARGB(255, 7, 7, 7)}) =>
    Container(
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
  child: Text(t, style: TextStyle(color: red ? Colors.red : Colors.deepOrange)),
);
