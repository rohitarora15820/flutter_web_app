import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'dart:io';



import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookie_wrapper/cookie.dart';



class FrappeServices extends StateNotifier {
  final StateNotifierProviderRef<FrappeServices, Object?> ref;

  FrappeServices(this.ref) : super(null) {
    onInit();
  }

  var dio = Dio();




  void onInit() {
    // Set up Dio options
    dio.options.baseUrl = 'https://demo.extensionerp.com/api';
    dio.options.connectTimeout = Duration(milliseconds: 10000);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };



    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.extra["withCredentials"] = true;
      return handler.next(options);
    }));
    // Add the InterceptorsWrapper to the Dio instance for cookie management
    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) {
    //
    //     log("cookiesData"+document.cookie.toString());
    //     // Read cookies from the browser's cookie storage
    //     var cookies = document.cookie!.split(';');
    //     var cookieHeader = cookies.map((cookie) => cookie.trim()).join('; ');
    //
    //     // Add the cookies to the request headers
    //     options.headers['Cookie'] = cookieHeader;
    //
    //     return handler.next(options);
    //   },
    //   onResponse: (response, handler) {
    //     // Save cookies from the response to the browser's cookie storage
    //     var setCookieHeaders = response.headers[HttpHeaders.setCookieHeader];
    //     if (setCookieHeaders != null) {
    //       for (var header in setCookieHeaders) {
    //         document.cookie = header;
    //       }
    //     }
    //
    //     return handler.next(response);
    //   },
    // ));

    // Add other interceptors as needed
    dio.interceptors.add(HttpFormatter());
  }

  String getSidCookie() {
    final cookies = document.cookie!.split(';');
    for (var cookie in cookies) {
      final parts = cookie.split('=');
      final name = parts[0].trim();
      final value = parts.length > 1 ? parts[1].trim() : '';
      if (name == 'sid') {
        return value;
      }
    }
    return ''; // Return empty string if sid cookie is not found
  }



  //Get function
  Future<Response> getFunction() async {
    try {
      Response response = await dio.get(
        'https://www.zohoapis.com/crm/v2/functions/api_for_beat_plan/actions/execute?auth_type=apikey&zapikey=1003.263c7c74852bfdd331b0ff052d7cf05d.f62395887890d6e8e30eb4abda7aef2a&sales_person=Rohit Arora&status=Pending&start_time=26/02/2024',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> customUrlFunction(String url) async {
    try {
      Response response = await Dio().get(
        'https://demo.extensionerp.com/$url',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'token e08939a9e449a47:0fb676cdc85bfb8',
          },
        ),
      );
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> getDeviceInfo(Map<String, dynamic> data) async {
    print("Body : $data");
    try {
      var mUrl = "https://app.posthog.com/capture/";
      Response response = await Dio().post(mUrl,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
          data: data);
      print("mRsponceived : ${response.statusCode}");
      return response;
    } on DioError {
      rethrow;
    }
  }



  Future<Response> login(String username, String password) async {
    try {
      Response response = await dio.post('/method/login', data: {
        'usr': username, 'pwd': password,
        // 'device': 'mobile'
      });

      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> getDoc(String doctype, String docname) async {
    try {
      Response response = await dio.get<Map<String, dynamic>>(
        '/resource/$doctype/$docname',
      );
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> newDoc(String doctype, {required Object data}) async {
    try {
      Response response = await dio.post(
        '/resource/$doctype',
        data: data,
      );

      return response;
    } on DioError catch (e) {
      EasyLoading.showError(e.response!.statusCode.toString());
      log(e.response!.data.toString());
      var x = json.decode(e.response!.data['_server_messages']);
      var server_message = x;
      log(server_message[0].toString());

      EasyLoading.showError(e.response!.statusCode.toString().contains("500")
          ? "Server Error ${server_message}"
          : "Unable to proceed request \n ${server_message}");
      rethrow;
    }
  }

  Future<Response> updateDoc(String doctype, String docname,
      {required Object data}) async {
    try {
      Response response = await dio
          .put<Map<String, dynamic>>('/resource/$doctype/$docname', data: data);
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> getDocFields({required String doctype}) async {
    try {
      Response response = await dio.post(
        '/method/frappe.desk.form.load.getdoctype?doctype=$doctype',
      );
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> getList(
      {required String doctype,
        List<List>? filters,
        List<String>? fields,
        int? startPageLength,
        int? startIndex,
        String? orderBy}) async {
    String url = '/resource/$doctype';

    try {
      final response =
      await dio.get<Map<String, dynamic>>(url, queryParameters: {
        'filters': jsonEncode(filters ?? []),
        'fields': jsonEncode(fields ?? []),
        "order_by": orderBy,
        "limit": 10,
        "limit_start": startIndex,
        "limit_page_length": startPageLength
      });
      return response;
    } on DioError catch (error) {
      throw FrappeException(
          error.response!.statusCode ?? 0, 'Failed to fetch documents');
    } on Exception {
      throw FrappeException(0, 'Failed to fetch documents');
    }
  }

  Future<Response> getLists(String doctype,
      {List<List>? filters,
        List<List>? orfilters,
        int? limit,
        String? orderBy,
        int? startPageLength,
        List<String>? fields,
        int? startIndex}) async {
    String subUrl = '/?limit=10';
    String newfields;
    if (limit != null) {
      subUrl = '/?limit=$limit';
    }
    if (filters != null) {
      subUrl = '$subUrl&filters=${jsonEncode(filters)}';
    }
    if (orfilters != null) {
      subUrl = '$subUrl&or_filters=${jsonEncode(orfilters)}';
    }
    if (startPageLength != null) {
      newfields = jsonEncode(fields);
      subUrl = '$subUrl&limit_page_length=$startPageLength';
    }

    if (fields != null) {
      newfields = jsonEncode(fields);
      subUrl = '$subUrl&fields=$newfields';
    }
    if (startIndex != null) {
      newfields = jsonEncode(fields);
      subUrl = '$subUrl&limit_start=$startIndex';
    }

    if (orderBy != null) {
      newfields = jsonEncode(fields);
      subUrl = '$subUrl&order_by=$orderBy';
    }
    // log('$baseUrl/api/resource/$doctype$subUrl');
    try {
      String url = '/resource/$doctype';
      Response response =
      await dio.get<Map<String, dynamic>>(url, queryParameters: {
        'filters': jsonEncode(filters ?? []),
        'fields': jsonEncode(fields ?? []),
        "order_by": orderBy
      });

      return response;
    } on DioError catch (error) {
      throw FrappeException(
          error.response!.statusCode ?? 0, 'Failed to fetch document');
    }
  }

  Future<bool> checkLogin() async {
    try {
      await dio.get('/method/frappe.auth.get_logged_user');
      return true;
    } on DioError catch (e) {
      log(e.response!.statusMessage.toString());
      return false;
    }
  }

  Future<Response> addAssignee({required Object data}) async {
    try {
      Response response =
      await dio.post('/method/frappe.desk.form.assign_to.add', data: data);
      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> logout(BuildContext context) async {
    EasyLoading.show();

    EasyLoading.show(status: 'Logging Out');
    try {
      Response response = await dio.get('/method/logout');
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Logout successfully");


      }
      EasyLoading.showSuccess('Logged Out');
      return response;
    } on DioError {
      EasyLoading.showError("Error");
      rethrow;
    }
  }

  Future<Response> fetchAssignee({required Object data}) async {
    try {
      Response response = await dio
          .post('/method/frappe.desk.form.load.get_docinfo', data: data);

      return response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> deleteAssignee({required Object data}) async {
    try {
      Response response = await dio
          .post('/method/frappe.desk.form.assign_to.remove', data: data);

      return response;
    } on DioError {
      rethrow;
    }
  }
}

final frappeProvider = StateNotifierProvider<FrappeServices, Object?>((ref) {
  return FrappeServices(ref);
});

class FrappeException implements Exception {
  final int code;
  final String message;

  FrappeException(this.code, this.message);

  @override
  String toString() {
    return 'FrappeException: $code - $message';
  }
}