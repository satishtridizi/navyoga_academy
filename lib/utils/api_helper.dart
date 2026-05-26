class ApiHelper {
  static bool isSuccess(dynamic res) {
    return res != null && res["success"] == true;
  }

  static String getMessage(dynamic res) {
    return res?["message"] ?? "Something went wrong";
  }
}
