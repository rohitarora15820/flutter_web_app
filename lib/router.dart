
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frappe_flutter_web_app/main.dart';
import 'package:go_router/go_router.dart';



var routerProvider = Provider(
      (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return  LoginPage();
        },
      ),
      GoRoute(
          path: '/home',
          builder: (context, state) {
            return  NextPage();
          }),


    ],
  ),
);
