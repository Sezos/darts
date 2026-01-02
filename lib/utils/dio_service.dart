import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

/// A simple wrapper for all API responses.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success:
          json['status'] == 200 ||
          json['success'] == true ||
          json['status'] == "success",
      data: json['data'] is bool
          ? (json['data'] == true ? {"success": true} : {"success": false})
          : json['data'] ?? ({"hehe": "hehe"} as Map<String, dynamic>),
      message: json['error']?['details'],
    );
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;
  ApiService._internal();
  Dio getInstance() {
    var url = GetStorage().read("base_url");

    url = url ?? "";
    url = url.replaceAll("http://", "");
    url = url.replaceAll("http:/", "");
    url = url.replaceAll("https://", "");
    url = url.replaceAll("https:/", "");

    url = "http://$url";

    return Dio(
      BaseOptions(
        validateStatus: (status) {
          return status! < 600;
        },
        baseUrl: url,
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    );
  }

  final GetStorage _storage = GetStorage();

  // =================  Public API Methods =================

  Future<dynamic> get(
    String url, {
    bool useToken = true,
    bool raw = false,
  }) async {
    try {
      final response = await getInstance().get(
        url,
        options: Options(headers: _authHeader(useToken)),
      );

      if (response.data is String) {
        throw "Сервэрт алдаа гарсан тул та түр хүлээгээд дахин оролдоно уу";
      }

      return raw ? response.data : _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String url,
    dynamic body, {
    bool useToken = true,
    bool raw = false,
  }) async {
    try {
      final response = await getInstance().post(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeader(useToken)),
      );

      if (response.data is String) {
        throw "Сервэрт алдаа гарсан тул та түр хүлээгээд дахин оролдоно уу";
      }

      return raw ? response.data : _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String url,
    dynamic body, {
    bool useToken = true,
  }) async {
    try {
      final response = await getInstance().put(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeader(useToken)),
      );

      if (response.data is String) {
        throw "Сервэрт алдаа гарсан тул та түр хүлээгээд дахин оролдоно уу";
      }

      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(
    String url,
    dynamic body, {
    bool useToken = true,
    bool raw = false,
  }) async {
    try {
      final response = await getInstance().patch(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeader(useToken)),
      );

      if (response.data is String) {
        throw "Сервэрт алдаа гарсан тул та түр хүлээгээд дахин оролдоно уу";
      }

      return raw ? response.data : _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    dynamic body,
    bool useToken = true,
  }) async {
    try {
      final response = await getInstance().delete(
        url,
        data: jsonEncode(body),
        options: Options(headers: _authHeader(useToken)),
      );

      if (response.data is String) {
        throw "Сервэрт алдаа гарсан тул та түр хүлээгээд дахин оролдоно уу";
      }

      return _parseResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // =================  Internal Helpers =================

  Map<String, dynamic>? _authHeader(bool useToken) {
    if (!useToken) return null;
    final token = _getToken();

    if (token == null || token.isEmpty) {
      return {};
    }

    return {'Authorization': 'Bearer $token'};
  }

  String? _getToken() => _storage.read('token');

  dynamic _parseResponse(Response<dynamic> response) {
    if (response.data is! Map<String, dynamic>) {
      throw 'Unexpected response format';
    }

    final json = response.data as Map<String, dynamic>;

    final apiResponse = ApiResponse.fromJson(json);
    if (apiResponse.message?.contains("Токен хүчингүй болсон байна") == true &&
        logout != null) {
      logout!();
    }
    if (apiResponse.success == false) {
      throw apiResponse.message ?? 'Алдаа гарлаа';
    }

    return apiResponse.data;
  }

  Function? logout;

  String _handleError(Object error) {
    if (error is DioException) {
      log("Handle Error: ", error: error);

      return error.message ?? 'Сүлжээний алдаа гарлаа';
    }
    return error.toString();
  }
}

final apiService = ApiService();

final post = apiService.post;
final get = apiService.get;
final delete = apiService.delete;
final put = apiService.put;
final patch = apiService.patch;
