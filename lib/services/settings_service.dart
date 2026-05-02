import 'package:navyoga_academy/models/settings_privacy_option_model.dart';

class SettingsService {
  Future<List<PrivacyOption>> fetchPrivacyOptions() async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate API

    return [
      PrivacyOption(title: "Download My Data"),
      PrivacyOption(title: "Privacy Policy"),
      PrivacyOption(title: "Terms of Service"),
      PrivacyOption(title: "Delete Account", isDanger: true),
    ];
  }
}
