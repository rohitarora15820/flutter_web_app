import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frappe_flutter_web_app/provider/data_provider.dart';
import 'package:frappe_flutter_web_app/router.dart';
import 'package:frappe_flutter_web_app/services/frappe_services.dart';

void main() {
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(frappeProvider);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    var router = ref.watch(routerProvider);
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp.router(
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
          ),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: "rohitarora@extensioncrm.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "Rohit@456");
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(getProvider).login(
                              _usernameController.text.toString(),
                              _passwordController.text.toString(),
                              context);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _checkSession(context),
          child: Text('Check Session'),
        ),
      ),
    );
  }

  Future<void> _checkSession(BuildContext context) async {
    try {
      final dio = Dio();
      dio.interceptors.add(HttpFormatter());

      final response = await dio.get(
        'https://demo.extensionerp.com/api/resource/Lead',
        // Add any necessary headers or parameters here
      );

      if (response.statusCode == 200) {
        // Handle successful response here
        print('API Response: ${response.data}');
      } else {
        throw Exception('Failed to make API request');
      }
    } catch (e) {
      // Handle errors
      print('API request failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API request failed. Please try again.'),
        ),
      );
    }
  }
}
