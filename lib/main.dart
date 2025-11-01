import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/expense_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(OnboardingController());
        Get.put(ExpenseController());
      }),
    );
  }
}
