import 'dart:convert';
import 'dart:developer';

import 'package:buckrate_calculator/constants/colors.dart';
import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/constants/lists.dart';
import 'package:buckrate_calculator/constants/strings.dart';
import 'package:buckrate_calculator/constants/utill.dart';
import 'package:buckrate_calculator/data/model/animal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  static const routeName = "/admin";
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  bool showProgress = false;
  bool refreshStatus = false;

  void refresh() {
    setState(() {
      refreshStatus = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        refreshStatus = false;
      });
    });
  }

  Future<Map> deleteAGoat(String id) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('$baseUrl/buckrate/delete/goat_data'));
    request.body = json.encode({"goat_id": id});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      log(response.reasonPhrase.toString());
    }
    return {};
  }

  Future<Map> sellAGoat(String mobile, String name, String id) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('$baseUrl/buckrate/update/sale_status'));
    request.body = json
        .encode({"buyer_name": name, "buyer_mobile": mobile, "goat_id": id});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return jsonDecode(await response.stream.bytesToString());
    } else {
      log(response.reasonPhrase.toString());
    }
    return {};
  }

  Future getSellingGoatsData(int status) async {
    var request = http.Request(
        'GET', Uri.parse('$baseUrl/buckrate/get/goat?sale-status=$status'));
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
      body: refreshStatus
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: getSellingGoatsData(0),
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
                              size:
                                  ResponsiveD.d(context) == ResponsiveD.desktop
                                      ? 50
                                      : 40,
                              color: kPrimaryColor,
                            ),
                            Text(
                              "Admin market",
                              style: GoogleFonts.righteous(
                                  textStyle: TextStyle(
                                fontSize: ResponsiveD.d(context) ==
                                        ResponsiveD.desktop
                                    ? 40
                                    : 30,
                                fontWeight: FontWeight.w500,
                              )),
                            ),
                            const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "आप यहां सभी जानवरों का प्रबंधन कर सकते हैं",
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
                                width: ResponsiveD.d(context) ==
                                        ResponsiveD.desktop
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
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
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
                      Text(data.sId!.substring(data.sId!.length - 5)),
                      const SizedBox(
                        width: 10,
                      ),
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

  Widget copyWidget({required String text, required Widget child}) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$text copied to clipboard")));
      },
      child: child,
    );
  }

  TextEditingController buyerNameController = TextEditingController();
  TextEditingController buyerPhoneController = TextEditingController();

  Widget goatDetailsDialog(Data data) {
    String fS =
        FAOBCSScoreList.where((element) => element["type"] == data.fAOBCSScore)
            .first["title"];
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
              IconButton(
                onPressed: () async {
                  bool? status = await showDialogC(
                    context: context,
                    child: AlertDialog(
                      title: const Text("आपको यकीन है"),
                      content: const Text("क्या आप इस पशु को हटाना चाहते हैं?"),
                      actions: [
                        TextButton(
                          child: const Text("नहीं"),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        TextButton(
                          child: const Text("हाँ"),
                          onPressed: () async {
                            Navigator.pop(context, true);
                          },
                        ),
                      ],
                    ),
                  );
                  if (status == true) {
                    if (ResponsiveD.d(context) != ResponsiveD.desktop) {
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("कृपया प्रतीक्षा करें"),
                      ),
                    );
                    var out = await deleteAGoat(data.sId!);
                    print(out);
                    if (out['status'] == "success") {
                      refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("पशु सफलतापूर्वक हटा दिया गया"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("कुछ गलत हो गया, कृपया पुनः प्रयास करें"),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
              ),
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
                      const DataCell(Text("पहचान")),
                      DataCell(Text(data.sId!.substring(data.sId!.length - 5)))
                    ],
                  ),
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
                      const DataCell(Text("किसान का मोबाइल नंबर")),
                      DataCell(
                        copyWidget(
                          text: data.farmerMobile.toString(),
                          child: Text(
                            data.farmerMobile.toString(),
                          ),
                        ),
                      )
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("किसान का पता")),
                      DataCell(
                        copyWidget(
                          text: data.fullAddress.toString(),
                          child: Text(
                            data.fullAddress.toString(),
                          ),
                        ),
                      )
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("मानचित्र")),
                      DataCell(
                        copyWidget(
                          text:
                              "https://maps.google.com?q=${data.location!.coordinates![0].toString()},${data.location!.coordinates![1].toString()}",
                          child: Text(
                              "${data.location!.coordinates![0].toString()},${data.location!.coordinates![1].toString()}"),
                        ),
                      )
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
                      const DataCell(Text("रेफरल मोबाइल")),
                      DataCell(copyWidget(
                          text: data.refralMobile.toString(),
                          child: Text(data.refralMobile!)))
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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: buyerNameController,
                decoration: const InputDecoration(hintText: 'खरीदार का नाम'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: buyerPhoneController,
                decoration:
                    const InputDecoration(hintText: 'खरीदार का मोबाइल नंबर'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (ResponsiveD.d(context) != ResponsiveD.desktop)
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
              StatefulBuilder(
                builder: (context, setState) {
                  return showProgress
                      ? const SizedBox(
                          width: 150,
                          child: LinearProgressIndicator(),
                        )
                      : FilledButton(
                          onPressed: () async {
                            if (buyerNameController.text.isEmpty ||
                                buyerPhoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "कृपया क्रेता का मोबाइल नंबर और क्रेता का नाम भरें")),
                              );
                              return;
                            } else {
                              setState(() {
                                showProgress = true;
                              });
                              var out = await sellAGoat(
                                  buyerPhoneController.text,
                                  buyerNameController.text,
                                  data.sId!);
                              if (out["status"] == "success") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("सफलतापूर्वक बेचा गया")),
                                );
                                refresh();
                                if (ResponsiveD.d(context) !=
                                    ResponsiveD.desktop) {
                                  Navigator.pop(context);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("सफलतापूर्वक बेचा गया")),
                                );
                              }
                              setState(() {
                                showProgress = false;
                              });
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "बेचो",
                            ),
                          ),
                        );
                },
              )
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
