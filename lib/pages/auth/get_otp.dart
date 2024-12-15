import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/pages/auth/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GetOtpPage extends StatefulWidget {
  const GetOtpPage({super.key});
  static const String routeName = "/login";

  @override
  State<GetOtpPage> createState() => _GetOtpPageState();
}

class _GetOtpPageState extends State<GetOtpPage> {
  final TextEditingController mobileNumberController = TextEditingController();
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
                "Welcome Back!",
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
                "ओटीपी प्राप्त करने के लिए अपना मोबाइल नंबर दर्ज करें",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: mobileNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'कृपया मोबाइल नंबर दर्ज करें';
                  } else if (value.length != 10) {
                    return 'कृपया वैध मोबाइल नंबर दर्ज करें';
                  } else if (value.startsWith("0")) {
                    return 'कृपया वैध मोबाइल नंबर दर्ज करें';
                  } else if (value.startsWith("+")) {
                    return 'कृपया वैध मोबाइल नंबर दर्ज करें';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  labelText: "मोबाइल नंबर",
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
                              context.go(VerifyOtpPage.routeName);
                            }
                          },
                          child: const Text("ओटीपी प्राप्त करें"),
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
