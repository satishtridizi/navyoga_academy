import 'package:navyoga_academy/models/settings_notification_model.dart';
import 'package:navyoga_academy/models/settings_payment_model.dart';
import 'package:navyoga_academy/models/settings_privacy_option_model.dart';
import 'package:navyoga_academy/models/settings_security_field_model.dart';

List<NotificationSetting> settingsData = [
  NotificationSetting(
    title: "Class Reminders",
    subtitle: "Get notified before classes",
    value: true,
  ),
];

List<SecurityField> securityFields = [
  SecurityField(label: "Current Password", hint: "Enter current password"),
];

List<PrivacyOption> privacyOptions = [
  PrivacyOption(title: "Delete Account", isDanger: true),
];

PaymentModel paymentData = PaymentModel(
  plan: "Premium Membership",
  status: "Active",
  validTill: "May 10, 2026",
  price: "₹999/month",
  card: "****1234",
  autoRenew: true,
);
