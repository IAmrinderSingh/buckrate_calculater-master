import 'dart:convert';
import 'dart:developer';

import 'package:buckrate_calculator/constants/colors.dart';
import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/constants/lists.dart';
import 'package:buckrate_calculator/constants/strings.dart';
import 'package:buckrate_calculator/constants/utill.dart';
import 'package:buckrate_calculator/data/model/animal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerDashboardPage extends StatefulWidget {
  static const routeName = "/buyer-dashboard";
  const BuyerDashboardPage({super.key});
  @override
  State<BuyerDashboardPage> createState() => _BuyerDashboardPageState();
}

class _BuyerDashboardPageState extends State<BuyerDashboardPage> {
  int selectedIndex = 0;

  Future getSellingGoatsData() async {
    var request =
        http.Request('GET', Uri.parse('$baseUrl/buckrate/get/unsold_goat'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      log(response.reasonPhrase.toString());
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getSellingGoatsData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AnimalDataModel animalDataModel =
                AnimalDataModel.fromJson(snapshot.data!);
            if (animalDataModel.data!.isEmpty) {
              return const Center(
                child: Text("बाजार में कोई पशु उपलब्ध नहीं है"),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: ResponsiveD.d(context) == ResponsiveD.desktop
                            ? 50
                            : 40,
                        color: kPrimaryColor,
                      ),
                      Text(
                        "Market",
                        style: GoogleFonts.righteous(
                            textStyle: TextStyle(
                          fontSize:
                              ResponsiveD.d(context) == ResponsiveD.desktop
                                  ? 40
                                  : 30,
                          fontWeight: FontWeight.w500,
                        )),
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              "आप यहां से पशु खरीद सकते हैं",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: animalDataModel.data!.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 15,
                              );
                            },
                            itemBuilder: (context, index) {
                              return getListBody(animalDataModel, index);
                            },
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveD.d(context) == ResponsiveD.desktop
                              ? 20
                              : 0,
                        ),
                        if (ResponsiveD.d(context) == ResponsiveD.desktop)
                          Expanded(
                            child: SingleChildScrollView(
                              child: cusCard(
                                child: goatDetailsDialog(
                                    animalDataModel.data![selectedIndex]),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("कुछ गलत हो गया, कृपया पुनः प्रयास करें"),
            );
          } else {
            return const Center(
              child: Text("बाजार में कोई पशु उपलब्ध नहीं है"),
            );
          }
        },
      ),
    );
  }

  InkWell getListBody(AnimalDataModel animalDataModel, int index) {
    Data data = animalDataModel.data![index];
    return InkWell(
      onTap: () {
        if (ResponsiveD.d(context) == ResponsiveD.desktop) {
          setState(() {
            selectedIndex = index;
          });
        } else {
          showDetailsDialog(data);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedIndex == index &&
                  ResponsiveD.d(context) == ResponsiveD.desktop
              ? Colors.white
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Image.asset(
                    "assets/${data.cattleType == "भेड़" ? "sheep_icon" : "goat_icon"}.png",
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data.cattleGender} ${data.cattleType}",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text("${data.cattleAge} महीने")
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (ResponsiveD.d(context) == ResponsiveD.desktop) {
                            setState(() {
                              selectedIndex = index;
                            });
                          } else {
                            showDetailsDialog(data);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            "पूरा ब्योरा",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      if (ResponsiveD.d(context) != ResponsiveD.desktop) ...[
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: () {
                            String whatsappMessage = """
नमस्ते, मैं एक पशु खरीदना चाहता हूँ। जिसका विवरण नीचे दिया गया है।
  
पशु की आईडी: ${data.sId!.substring(data.sId!.length - 5)}
पशु का प्रकार: ${data.cattleType}
पशु का लिंग: ${data.cattleGender}
पशु का उम्र: ${data.cattleAge}
पशु का वजन: ${data.cattleWeight}
पशु की कीमत: ₹${data.cattlePrice}
      """;
                            launchUrl(Uri.parse(
                                "https://wa.me/$tmMobileNo?text=$whatsappMessage"));
                          },
                          icon: Image.asset(
                            "assets/WhatsApp_icon.png",
                            height: 18,
                            width: 18,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              "ऑर्डर करें",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                          ),
                        ),
                      ]
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: ShapeDecoration(
                    color: const Color(0x2D11AA72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      data.farmerName.toString(),
                    ),
                  ),
                ),
                Text(
                  "₹${data.cattlePrice}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showDetailsDialog(Data data) {
    showDialogC(
      context: context,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: goatDetailsDialog(data),
          ),
        ),
      ),
    );
  }

  Widget goatDetailsDialog(Data data) {
    String whatsappMessage = """
नमस्ते, मैं एक पशु खरीदना चाहता हूँ। जिसका विवरण नीचे दिया गया है।
  
पशु की आईडी: ${data.sId!.substring(data.sId!.length - 5)}
पशु का प्रकार: ${data.cattleType}
पशु का लिंग: ${data.cattleGender}
पशु का उम्र: ${data.cattleAge}
पशु का वजन: ${data.cattleWeight}
पशु की कीमत: ₹${data.cattlePrice}
      """;
    String fS =
        FAOBCSScoreList.where((element) => element["type"] == data.fAOBCSScore)
            .first["title"];
    var filledButton = FilledButton.icon(
      onPressed: () {
        launchUrl(Uri.parse("https://wa.me/$tmMobileNo?text=$whatsappMessage"));
      },
      icon: Image.asset(
        "assets/WhatsApp_icon.png",
        height: 30,
        width: 30,
      ),
      label: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "ऑर्डर करें",
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Image.asset(
                      "assets/${data.cattleType == "भेड़" ? "sheep_icon" : "goat_icon"}.png",
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "पशु का विवरण",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              if (ResponsiveD.d(context) == ResponsiveD.desktop) filledButton,
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text(""),
                  ),
                  DataColumn(
                    label: Text("विवरण"),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु का प्रकार")),
                      DataCell(Text(data.cattleType.toString()))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु का लिंग")),
                      DataCell(Text(data.cattleGender.toString()))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु का उम्र")),
                      DataCell(Text("${data.cattleAge} महीने"))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु का वजन")),
                      DataCell(Text("${data.cattleWeight}kg"))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु की कीमत")),
                      DataCell(Text("₹${data.cattlePrice}"))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("प्रति किलो दर")),
                      DataCell(Text(
                          "₹${(data.cattlePrice! / data.cattleWeight!).toStringAsFixed(0)}"))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("किसान का नाम")),
                      DataCell(Text(data.farmerName.toString()))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("भुगतान मोड")),
                      DataCell(Text(data.paymentMode!.join(", ")))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("पशु की शारीरिक स्थिति")),
                      DataCell(Text(fS))
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("समय")),
                      DataCell(
                        Text(
                          DateFormat("dd-MM-yyyy hh:mm a").format(
                            DateTime.fromMillisecondsSinceEpoch(
                              (data.addedTime! * 1000).toInt(),
                            ).toLocal(),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (ResponsiveD.d(context) != ResponsiveD.desktop)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("बंद करें"),
                  ),
                ),
                const SizedBox(width: 10),
                filledButton,
              ],
            ),
          )
      ],
    );
  }

  Widget cusCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: child,
      ),
    );
  }
}
