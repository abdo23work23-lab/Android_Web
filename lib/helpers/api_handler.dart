
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';


class ApiHandler {
  static Dio? dio;

  static init() {
    debugPrint('dio helper run');
    dio = Dio(BaseOptions(
      validateStatus: (_) => true,
      baseUrl: 'https://shakshask15.marketopiateam.com',
      receiveDataWhenStatusError: true,
    ));
  }


  static Future<Response> postData({
    required String url,
    var data,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    return dio!.post(
      url,
      data: data,
      queryParameters: query,
      options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          }),
    );
  }

}
