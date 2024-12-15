import 'package:buckrate_calculator/constants/colors.dart';
import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            Icon(
              Icons.settings_outlined,
              size: ResponsiveD.d(context) == ResponsiveD.desktop ? 50 : 40,
              color: kPrimaryColor,
            ),
            Text(
              "Settings",
              style: GoogleFonts.righteous(
                  textStyle: TextStyle(
                fontSize:
                    ResponsiveD.d(context) == ResponsiveD.desktop ? 40 : 30,
                fontWeight: FontWeight.w500,
              )),
            ),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    "ऐप की सेटिंग बदलें",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ListTile(
              onTap: () {
                launchUrlString(companyTNCUrl);
              },
              leading: const CircleAvatar(
                child: Icon(
                  Icons.privacy_tip_outlined,
                ),
              ),
              title: const Text("नियम और शर्तें"),
              trailing: const Icon(
                Icons.open_in_new,
              ),
            )
          ],
        ),
      ),
    );
  }
}
