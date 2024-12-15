import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});
  static const String routeName = "/verify-otp-page";

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: ResponsiveD.d(context) == ResponsiveD.desktop
              ? MediaQuery.of(context).size.width * 0.3
              : ResponsiveD.d(context) == ResponsiveD.tablet
                  ? MediaQuery.of(context).size.width * 0.1
                  : 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Icon(
                Icons.login_outlined,
                size: 50,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Verify OTP!",
                style: GoogleFonts.righteous(
                  textStyle: TextStyle(
                    fontSize:
                        ResponsiveD.d(context) == ResponsiveD.desktop ? 40 : 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "लॉगिन करने के लिए अपना ओटीपी सत्यापित करें",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया ओटीपी दर्ज करें';
                  } else if (value.length != 6) {
                    return 'कृपया वैध ओटीपी दर्ज करें';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  labelText: "ओटीपी",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isLoading
                      ? const SizedBox(
                          width: 150,
                          child: LinearProgressIndicator(),
                        )
                      : FilledButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.go(HomePage.routeName);
                            }
                          },
                          child: const Text("ओटीपी सत्यापित करें"),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
