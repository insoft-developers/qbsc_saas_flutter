class ApiEndpoint {
  // Auth
  static const String login = "/login";
  static const String register = "/auth/register";
  static const String verifyFace = '/verify_face';
  static const String absenActive = '/absen_active';
  static const String locationData = '/location_data';
  static const String getDataLocation = '/get_data_location';

  // User
  static const String profile = "/user/profile";
  static const String updateProfile = "/user/update";

  // Quiz, Leaderboard, dst (sesuai project kamu)
  static const String leaderboard = "/quiz/leaderboard";
}
