// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:package_info_plus/package_info_plus.dart';
// import 'package:uuid/uuid.dart';

// class DeviceService {
//   static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

//   static final Uuid _uuid = const Uuid();

//   static Future<String> getUniqueId() async {
//     try {
//       if (Platform.isAndroid) {
//         final info = await _deviceInfo.androidInfo;
//         return info.id;
//       } else if (Platform.isIOS) {
//         final info = await _deviceInfo.iosInfo;
//         return info.identifierForVendor ?? "unknown-ios";
//       } else if (Platform.isMacOS) {
//         final info = await _deviceInfo.macOsInfo;
//         return info.systemGUID ?? "unknown-macos";
//       } else if (Platform.isWindows) {
//         final info = await _deviceInfo.windowsInfo;
//         return info.deviceId;
//       } else if (Platform.isLinux) {
//         final info = await _deviceInfo.linuxInfo;
//         return info.machineId ?? "unknown-linux";
//       } else {
//         return "unknown-device";
//       }
//     } catch (_) {
//       // Fallback: generate a random but consistent UUID
//       return _uuid.v4();
//     }
//   }

//   /// Get app version information
//   // static Future<String> getAppVersion() async {
//   // final info = await PackageInfo.fromPlatform();
//   // return info.version;
//   // }

//   static Future<String> getFcmToken() async {
//     try {
//       final fcm = FirebaseMessaging.instance;

//       if (Platform.isIOS || Platform.isMacOS) {
//         final settings = await fcm.requestPermission(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//         if (settings.authorizationStatus == AuthorizationStatus.denied) {
//           throw Exception('Push notification permission denied');
//         }
//       }

//       // 2. Ensure APNs token exists for iOS/macOS
//       if (Platform.isIOS || Platform.isMacOS) {
//         final apnsToken = await fcm.getAPNSToken();
//         if (apnsToken == null) {
//           await Future.delayed(const Duration(seconds: 2));
//         }
//       }

//       // 3. Now fetch the actual FCM token
//       final token = await fcm.getToken();
//       if (token == null) throw Exception("Failed to retrieve FCM token");

//       return token;
//     } catch (e) {
//       return "";
//     }
//   }
// }
