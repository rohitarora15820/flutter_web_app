import 'dart:async';
import 'dart:developer';



import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';





import '../leadnamemodel.dart';

import '../services/frappe_services.dart';


class DataProvider {
  final ProviderRef ref;

  DataProvider(
      this.ref,
      );


  validateLogin(BuildContext context) async {

    bool checkLogin = await ref.read(frappeProvider.notifier).checkLogin();
    log("checkLogin"+checkLogin.toString());
    if ( checkLogin) {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).push('/home');
    } else {
      // ignore: use_build_context_synchronously
      GoRouter.of(context).push('/');
    }
  }

  Future login(String? uName, String? password, BuildContext context) async {
    EasyLoading.show(status: "Please Wait");
    try {

      var response = await ref
          .read(frappeProvider.notifier)
          .login(uName.toString(), password.toString());

      if (response.statusCode == 200) {
        log(response.data.toString());

          validateLogin(context);

        EasyLoading.showSuccess("Successfully Logged In");
      }
      return response;
    } catch (e) {
      if (e is DioError) {
        if (e.response?.statusCode == 401) {
          EasyLoading.showError("Invalid credentials");
        } else {
          EasyLoading.showError("Server Error");
        }
      }
      EasyLoading.dismiss();
      rethrow;
    }
  }
  Future<List<LeadNameModel>> getData() async {
    List<LeadNameModel> leadList = [];

    EasyLoading.show(status: "Please Wait");

    var response =
    await ref.read(frappeProvider.notifier).getList(doctype:"Lead", fields: ["*"]);

    if (response.statusCode == 200) {
      response.data["data"].forEach((data) {
        leadList.add(LeadNameModel.fromJson(data));
      });
      EasyLoading.dismiss();
    }
    return leadList;
  }



}

final getProvider = Provider<DataProvider>((ref) => DataProvider(ref));
