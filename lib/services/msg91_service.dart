import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

class Msg91Service {
  static const String widgetId = "3665686e4870343638373938";
  static const String authToken = "514989Tc5jkfne7f86a12e39bP1";
  Msg91Service() {
    OTPWidget.initializeWidget(widgetId, authToken);
  }

  Future<Map<String, dynamic>?> sendOtp(String phone) async {
    final payload = {"identifier": phone};

    return await OTPWidget.sendOTP(payload);
  }

  Future<Map<String, dynamic>?> verifyOtp({
    required String reqId,
    required String otp,
  }) async {
    final payload = {"reqId": reqId, "otp": otp};

    final result = await OTPWidget.verifyOTP(payload);

    print("VERIFY OTP RESULT = $result");

    return result;
  }

  Future<Map<String, dynamic>?> retryOtp(String reqId) async {
    final payload = {"reqId": reqId};

    return await OTPWidget.retryOTP(payload);
  }
}
