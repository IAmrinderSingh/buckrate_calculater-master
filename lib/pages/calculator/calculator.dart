import 'dart:async';
import 'dart:convert';
import 'dart:developer';

// import 'dart:ffi';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:buckrate_calculator/constants/colors.dart';
import 'package:buckrate_calculator/constants/enums.dart';
import 'package:buckrate_calculator/constants/lists.dart';
import 'package:buckrate_calculator/constants/strings.dart';
import 'package:buckrate_calculator/constants/utill.dart';
import 'package:buckrate_calculator/pages/recommendation/recommendation_breading.dart';
import 'package:buckrate_calculator/widget/iframe_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/src/media_type.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/place_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CalculatorPage extends StatefulWidget {
  static const String routeName = "/calculator";
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  LocationResult? selectedLocation;
  CalculatorType? typeOfCalculator = CalculatorType.length;
  CalculatorStep calculatorStep = CalculatorStep.priceCalculate;
  TextEditingController chestGirthController = TextEditingController();
  TextEditingController lengthGirthController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController referencePersonHeightFTController =
      TextEditingController();
  TextEditingController referencePersonHeightInchController =
      TextEditingController(text: "0");
  TextEditingController farmerNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController fullAddressController = TextEditingController();
  TextEditingController goatAgeController = TextEditingController();
  TextEditingController referralMobileNoController = TextEditingController();
  PlatformFile? pickedFile;
  bool showLoadingIndicator = false;
  bool showErrorTextImageNotFound = false;
  bool showErrorTextPaymentModeNotFound = false;
  bool showErrorTextLocationNotFound = false;
  String? gender;
  String? animalType;
  List<String> paymentMode = [];
  String? faoScoreType;

  findLengthGirth() {
    if (chestGirthController.text.isNotEmpty &&
        gender != null &&
        goatAgeController.text.isNotEmpty) {
      double ageX = double.parse(goatAgeController.text);
      double ch = double.parse(chestGirthController.text);
      double factorY = 0.0;
      if (gender == "नर") {
        if (ageX <= 3) {
          factorY = twoPointEquation(0, 0, 3, 1.54, ageX);
        } else if (ageX > 3 && ageX <= 6) {
          factorY = twoPointEquation(3, 1.54, 6, 1.21, ageX);
        } else if (ageX > 6 && ageX < 14) {
          factorY = twoPointEquation(6, 1.21, 14, 3.1, ageX);
        } else if (ageX >= 14) {
          factorY = 3.1;
        }
      } else {
        if (ageX <= 3) {
          factorY = twoPointEquation(0, 0, 3, 1.98, ageX);
        } else if (ageX > 3 && ageX <= 6) {
          factorY = twoPointEquation(3, 1.98, 6, 2.81, ageX);
        } else if (ageX > 6 && ageX < 14) {
          factorY = twoPointEquation(6, 2.81, 14, 4.07, ageX);
        } else if (ageX >= 14) {
          factorY = 4.07;
        }
      }
      lengthGirthController.text = (ch - factorY).toStringAsFixed(2);
    }
  }

  Future<void> chooseLocation() async {
    selectedLocation = await showDialogC(
      context: context,
      verticalPadding: MediaQuery.of(context).size.height * 0.1,
      child: PlacePicker(
        googleMapApiKeyConst,
        baseUrl!,
        showNearByPlaces: false,
        appBarBackgroundColor: Colors.white,
        localizationItem: LocalizationItem(
          languageCode: 'hi_IN',
          nearBy: 'निकटवर्ती स्थान',
          findingPlace: 'जगह ढूंढी जा रही है...',
          noResultsFound: 'कोई परिणाम नहीं मिला',
          unnamedLocation: 'अनाम स्थान',
          tapToSelectLocation: 'इस स्थान को चुनने के लिए टैप करें',
        ),
      ),
    );
    setState(() {});
  }

  final Map<String, DateTime> festivalDates = {
    'Eid': DateTime(2024, 4, 10), // Example: This date changes each year
    'Holi': DateTime(2024, 3, 25),
    'Diwali': DateTime(2024, 10, 31),
    'Rakshabandhan': DateTime(2024, 8, 19),
    'Navratri': DateTime(2024, 10, 10),
    'Makarsankranti': DateTime(2024, 1, 14),
  };

  DateTime? getNextFestivalDate() {
    final today = DateTime.now();
    for (var date in festivalDates.values) {
      if (date.isAfter(today)) {
        return date;
      }
    }
    return null; // No upcoming festivals found
  }

  double adjustPrice(double basePrice) {
    final nextFestivalDate = getNextFestivalDate();
    if (nextFestivalDate != null) {
      // Calculate difference in days
      final today = DateTime.now();
      final daysUntilFestival = nextFestivalDate.difference(today).inDays;

      // Increase price if within 45 days of the festival
      if (daysUntilFestival <= 45) {
        return basePrice * 1.2; // Increase by 20%
      }
    }
    return basePrice; // No increase
  }

  String priceCalculator(double weight) {
    Map aT = animalTypesList.where((e) => e['type'] == animalType).first;
    Map gT = genders.where((e) => e['type'] == gender).first;
    double basePrize = adjustPrice(aT['price']);
    double age = double.parse(goatAgeController.text);
    double price = 0.0;
    double factorAge = 0.0;
    if (gender == "मादा") {
      if (age <= 2) {
        factorAge = 0.7;
      } else if (age > 2 && age <= 7) {
        factorAge = 0.97;
      } else if (age > 7 && age <= 14) {
        factorAge = 1;
      } else if (age > 14 && age <= 18) {
        factorAge = 0.9;
      } else if (age > 18 && age <= 24) {
        factorAge = 0.8;
      } else if (age > 24 && age <= 29) {
        factorAge = 0.7;
      } else {
        factorAge = 0.5;
      }
    } else {
      if (age <= 2) {
        factorAge = 0.7;
      } else if (age > 2 && age <= 14) {
        factorAge = 1;
      } else if (age > 14 && age <= 18) {
        factorAge = 0.9;
      } else if (age > 18 && age <= 24) {
        factorAge = 0.8;
      } else if (age > 24 && age <= 29) {
        factorAge = 0.7;
      } else {
        factorAge = 0.5;
      }
    }
    price = (weight * basePrize * factorAge * gT['price']);

    return (price).toStringAsFixed(0);
  }

  void getWeightFromImage() async {
    if (pickedFile != null &&
        referencePersonHeightFTController.text.isNotEmpty &&
        goatAgeController.text.isNotEmpty &&
        gender != null &&
        animalType != null &&
        faoScoreType != null) {
      setState(() {
        showLoadingIndicator = true;
      });
      try {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$baseUrl/buckrate/calculate_goat_rate'));
        request.fields.addAll({
          'refrence_man_height':
              "${referencePersonHeightFTController.text} ft ${referencePersonHeightInchController.text} inch"
        });
        request.files.add(
          http.MultipartFile.fromBytes('image', pickedFile!.bytes!,
              filename: pickedFile!.name,
              contentType: MediaType('image', pickedFile!.extension!)),
        );
        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          var out = jsonDecode(await response.stream.bytesToString());
          if (out != null) {
            if (out['weight'] != null) {
              Map fT =
                  FAOBCSScoreList.where((e) => e['type'] == faoScoreType).first;
              weightController.text =
                  (fT['price'] * out['weight']).toStringAsFixed(2);
              valueController.text =
                  priceCalculator(double.parse(weightController.text));
            }
          }
        } else {
          log(response.reasonPhrase.toString());
        }
      } on Exception catch (e) {
        log(e.toString());
      }
      setState(() {
        showLoadingIndicator = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "कृपया पशु की छवि चुनें, संदर्भ व्यक्ति की ऊंचाई जोड़ें और पशु का लिंग चुनें"),
        ),
      );
    }
  }

  void iWantToSell() {
    if (_formKey.currentState!.validate()) {
      pickedFile = null;
      setState(() {
        calculatorStep = CalculatorStep.formFill;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("सबसे पहले पशु का मूल्य और वजन ज्ञात करें"),
        ),
      );
    }
  }

  void back() {
    setState(() {
      calculatorStep = CalculatorStep.priceCalculate;
    });
  }

  Future<dynamic> sendEmailFunc() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/buckrate/send_email'));
      request.fields.addAll({
        'send_to': json.encode(["buckrate47@gmail.com"]),
        'subject': 'Buckrate calculator | ${farmerNameController.text}',
        'text': """
        A user on our app has expressed interest in selling a goat, and they have provided the following details:

        Farmer Name: ${farmerNameController.text}
        Mobile Number: ${mobileNoController.text}
        Full Address: ${fullAddressController.text}
        Animal's Weight: ${weightController.text} kg
        Price: ${valueController.text} Rs/
        Animal's type: $animalType
        Animal's Age: ${goatAgeController.text} months
        Animal's gender: $gender
        Animal's health score: $faoScoreType
        Referral mobile number: ${referralMobileNoController.text}
        Payment mode to farmer: ${paymentMode.join(", ")}
        Map: https://www.google.com/maps/search/?api=1&query=${selectedLocation!.latLng!.latitude},${selectedLocation!.latLng!.longitude}
        """
      });
      // request.files.add(
      //   http.MultipartFile.fromBytes('image', pickedFile!.bytes!,
      //       filename: pickedFile!.name,
      //       contentType: MediaType('image', pickedFile!.extension!)),
      // );
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var out = jsonDecode(await response.stream.bytesToString());
        return out;
      } else {
        return response.reasonPhrase.toString();
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<dynamic> saveDataFunc() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('$baseUrl/buckrate/add/goat'));
      request.body = json.encode({
        "farmer_name": farmerNameController.text,
        "farmer_mobile": mobileNoController.text,
        "full_address": fullAddressController.text,
        "cattle_type": animalType,
        "cattle_gender": gender,
        "cattle_age": double.parse(goatAgeController.text),
        "cattle_weight": double.parse(weightController.text),
        "cattle_price": int.parse(valueController.text),
        "refral_mobile": referralMobileNoController.text,
        "payment_mode": paymentMode,
        "FAOBCS_score": faoScoreType,
        "cattle_video": [],
        "cattle_image": [],
        "longitude": selectedLocation!.latLng!.longitude,
        "latitude": selectedLocation!.latLng!.latitude,
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var out = jsonDecode(await response.stream.bytesToString());
        return out;
      } else {
        return response.reasonPhrase.toString();
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  sendToWh() async {
    String textData = """
मैं एक बकरी बेचने में रुचि व्यक्त कर रहा हूँ, और मैंने निम्नलिखित विवरण प्रदान किया है:

किसान का नाम: ${farmerNameController.text}\n 
किसान का मोबाइल नंबर: ${mobileNoController.text}\n 
किसान का पूरा पता: ${fullAddressController.text}\n 

पशु का प्रकार: $animalType\n 
पशु का लिंग: $gender\n 
पशु की आयु: ${goatAgeController.text} महीने\n 
पशु का वजन: ${weightController.text} किलोग्राम\n 
पशु की कीमत: ${valueController.text} रुपये/\n 
पशु का स्वास्थ्य स्कोर: $faoScoreType\n 

रेफ़रल मोबाइल नंबर: ${referralMobileNoController.text}\n 
किसान को भुगतान का तरीका: ${paymentMode.join(", ")}\n 
मानचित्र: https://www.google.com/maps/search/?api=1&query=${selectedLocation!.latLng!.latitude},${selectedLocation!.latLng!.longitude}\n 

""";
    launchUrlString("https://wa.me/919216600320?text=$textData");
  }

  void sellNow() async {
    if (_formKey.currentState!.validate() &&
        paymentMode.isNotEmpty &&
        selectedLocation != null) {
      setState(() {
        showLoadingIndicator = true;
        showErrorTextImageNotFound = false;
        showErrorTextPaymentModeNotFound = false;
        showErrorTextLocationNotFound = false;
        calculatorStep = CalculatorStep.submit;
      });
      sendToWh();
      // List outs = await Future.wait([
      //   sendEmailFunc(),
      //   saveDataFunc(),
      // ]);
      // if ((outs[0] ?? {})['status'] == 'success' &&
      //     (outs[1] ?? {})['status'] == 'success') {
      //   farmerNameController.clear();
      //   mobileNoController.clear();
      //   fullAddressController.clear();
      //   weightController.clear();
      //   valueController.clear();
      //   goatAgeController.clear();
      //   pickedFile = null;
      // }
      setState(() {
        showLoadingIndicator = false;
      });
    } else {
      setState(() {
        showErrorTextImageNotFound = true;
        if (paymentMode.isEmpty) {
          showErrorTextPaymentModeNotFound = true;
        }
        if (selectedLocation == null) {
          showErrorTextLocationNotFound = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("कृपया उपरोक्त सभी विवरण जोड़ें"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget chooseCalculatorTypeWidget = cusCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "आप पशु का वजन कैसे पता करना चाहते हैं?",
            style: TextStyle(
              fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 20 : 22,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Radio<CalculatorType>(
                groupValue: typeOfCalculator,
                value: CalculatorType.length,
                onChanged: (v) {
                  setState(() {
                    typeOfCalculator = v;
                  });
                  weightController.clear();
                  valueController.clear();
                  lengthGirthController.clear();
                  chestGirthController.clear();
                },
              ),
              Text(
                "मेरे पास फ़ीता है",
                style: TextStyle(
                  fontSize:
                      ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : null,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  size: 17,
                ),
                onPressed: () {
                  launchUrlString(
                      "https://www.youtube.com/watch?v=BGNdds5PK68");
                },
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          // Row(
          //   children: [
          //     Radio<CalculatorType>(
          //       groupValue: typeOfCalculator,
          //       value: CalculatorType.image,
          //       onChanged: (v) {
          //         setState(() {
          //           typeOfCalculator = v;
          //         });
          //         weightController.clear();
          //         valueController.clear();
          //         pickedFile = null;
          //         referencePersonHeightFTController.clear();
          //         referencePersonHeightInchController.clear();
          //       },
          //     ),
          //     Text(
          //       "मेरे पास कैमरा है",
          //       style: TextStyle(
          //         fontSize:
          //             ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : null,
          //       ),
          //     ),
          //     IconButton(
          //       icon: const Icon(
          //         Icons.open_in_new,
          //         size: 17,
          //       ),
          //       onPressed: () {
          //         launchUrlString(
          //             "https://www.youtube.com/watch?v=ks8XeL-VEgA");
          //       },
          //     ),
          //   ],
          // ),
          // const SizedBox(
          //   height: 5,
          // ),
          Row(
            children: [
              Radio<CalculatorType>(
                groupValue: typeOfCalculator,
                value: CalculatorType.weight,
                onChanged: (v) {
                  setState(() {
                    typeOfCalculator = v;
                  });
                  weightController.clear();
                  valueController.clear();
                },
              ),
              Text(
                "मुझे पशु का वज़न पता है",
                style: TextStyle(
                  fontSize:
                      ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: ResponsiveD.d(context) == ResponsiveD.desktop
                              ? 50
                              : 40,
                          color: kPrimaryColor,
                        ),
                        Text(
                          "Buckrate Calculator",
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
                                "अपनी पशु की कीमत की गणना करें और ऑनलाइन बेचें",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  if (ResponsiveD.d(context) == ResponsiveD.desktop) ...[
                    const Spacer(),
                    const CurrentPriceWidget()
                  ],
                ],
              ),
              const SizedBox(height: 30),
              Visibility(
                visible: calculatorStep == CalculatorStep.priceCalculate,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Visibility(
                        visible: typeOfCalculator == CalculatorType.length,
                        child: createResponsiveCalculatorPart(
                          left: Column(
                            children: [
                              chooseCalculatorTypeWidget,
                              const SizedBox(
                                height: 20,
                              ),
                              cusCard(
                                child: Column(
                                  children: [
                                    Image.asset("assets/length.jpg"),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    textFormFieldFunc(
                                      controller: chestGirthController,
                                      keyboardType: TextInputType.number,
                                      labelText: "छाती का घेरा (Chest Girth)*",
                                      hintText:
                                          "छाती का घेरा को इंच डाले (in inch)",
                                      onChanged: (v) {
                                        if (chestGirthController
                                                .text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            animalType != null &&
                                            faoScoreType != null) {
                                          double chestGirth = double.parse(
                                              chestGirthController.text);
                                          findLengthGirth();
                                          double lengthGirth = double.parse(
                                              lengthGirthController.text);
                                          Map fT = FAOBCSScoreList.where((e) =>
                                              e['type'] == faoScoreType).first;
                                          double weight = (chestGirth *
                                                  chestGirth *
                                                  lengthGirth) /
                                              660;
                                          weightController.text =
                                              (weight * fT['price'])
                                                  .toStringAsFixed(2);
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          weightController.clear();
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया छाती का घेरा दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          right: Column(
                            children: [
                              cusCard(
                                  child: Column(
                                children: [
                                  dropdownButtonFromFieldFunc(
                                    hintText: "पशु का प्रकार*",
                                    typeOfGoat: animalType,
                                    dataTypes: animalTypesList,
                                    onChanged: (v) {
                                      setState(() {
                                        animalType = v.toString();
                                      });
                                      if (chestGirthController
                                              .text.isNotEmpty &&
                                          goatAgeController.text.isNotEmpty &&
                                          gender != null &&
                                          animalType != null &&
                                          faoScoreType != null) {
                                        double chestGirth = double.parse(
                                            chestGirthController.text);
                                        findLengthGirth();
                                        double lengthGirth = double.parse(
                                            lengthGirthController.text);
                                        double weight = (chestGirth *
                                                chestGirth *
                                                lengthGirth) /
                                            660;
                                        Map fT = FAOBCSScoreList.where((e) =>
                                            e['type'] == faoScoreType).first;
                                        weightController.text =
                                            (weight * fT['price'])
                                                .toStringAsFixed(2);
                                        valueController.text = priceCalculator(
                                            double.parse(
                                                weightController.text));
                                      } else {
                                        weightController.clear();
                                        valueController.clear();
                                      }
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "कृपया पशु का प्रकार चुनें";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  dropdownButtonFromFieldFunc(
                                    hintText: "पशु का लिंग (Gender)*",
                                    typeOfGoat: gender,
                                    dataTypes: genders,
                                    onChanged: (v) {
                                      setState(() {
                                        gender = v.toString();
                                      });
                                      if (chestGirthController
                                              .text.isNotEmpty &&
                                          goatAgeController.text.isNotEmpty &&
                                          gender != null &&
                                          animalType != null &&
                                          faoScoreType != null) {
                                        double chestGirth = double.parse(
                                            chestGirthController.text);
                                        findLengthGirth();
                                        double lengthGirth = double.parse(
                                            lengthGirthController.text);
                                        double weight = (chestGirth *
                                                chestGirth *
                                                lengthGirth) /
                                            660;
                                        Map fT = FAOBCSScoreList.where((e) =>
                                            e['type'] == faoScoreType).first;
                                        weightController.text =
                                            (weight * fT['price'])
                                                .toStringAsFixed(2);
                                        valueController.text = priceCalculator(
                                            double.parse(
                                                weightController.text));
                                      } else {
                                        weightController.clear();
                                        valueController.clear();
                                      }
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "कृपया पशु का लिंग चुनें";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  textFormFieldFunc(
                                    controller: goatAgeController,
                                    keyboardType: TextInputType.number,
                                    labelText: "महीनों में पशु की उम्र (Age)*",
                                    hintText: "महीनों में पशु की उम्र",
                                    onChanged: (v) {
                                      if (chestGirthController
                                              .text.isNotEmpty &&
                                          goatAgeController.text.isNotEmpty &&
                                          gender != null &&
                                          animalType != null &&
                                          faoScoreType != null) {
                                        double chestGirth = double.parse(
                                            chestGirthController.text);
                                        findLengthGirth();
                                        double lengthGirth = double.parse(
                                            lengthGirthController.text);
                                        double weight = (chestGirth *
                                                chestGirth *
                                                lengthGirth) /
                                            660;
                                        Map fT = FAOBCSScoreList.where((e) =>
                                            e['type'] == faoScoreType).first;
                                        weightController.text =
                                            (weight * fT['price'])
                                                .toStringAsFixed(2);
                                        valueController.text = priceCalculator(
                                            double.parse(
                                                weightController.text));
                                      } else {
                                        weightController.clear();
                                        valueController.clear();
                                      }
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "कृपया पशु की उम्र दर्ज करें";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )),
                              const SizedBox(
                                height: 20,
                              ),
                              cusCard(
                                child: chooseBodyTypeForFOA(
                                  onChanged: (v) {
                                    setState(() {
                                      faoScoreType = v.toString();
                                    });
                                    if (chestGirthController.text.isNotEmpty &&
                                        goatAgeController.text.isNotEmpty &&
                                        gender != null &&
                                        animalType != null &&
                                        faoScoreType != null) {
                                      double chestGirth = double.parse(
                                          chestGirthController.text);
                                      findLengthGirth();
                                      double lengthGirth = double.parse(
                                          lengthGirthController.text);
                                      double weight = (chestGirth *
                                              chestGirth *
                                              lengthGirth) /
                                          660;
                                      Map fT = FAOBCSScoreList.where(
                                              (e) => e['type'] == faoScoreType)
                                          .first;
                                      weightController.text =
                                          (weight * fT['price'])
                                              .toStringAsFixed(2);
                                      valueController.text = priceCalculator(
                                          double.parse(weightController.text));
                                    } else {
                                      weightController.clear();
                                      valueController.clear();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              if (weightController.text.isNotEmpty &&
                                  valueController.text.isNotEmpty)
                                cusCard(
                                    child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    textFormFieldFunc(
                                      controller: weightController,
                                      keyboardType: TextInputType.number,
                                      labelText: "वज़न (Weight)",
                                      hintText: "वज़न (in kg)",
                                      enabled: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया वज़न दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    textFormFieldFunc(
                                      controller: valueController,
                                      keyboardType: TextInputType.number,
                                      labelText: "कीमत (Value)",
                                      hintText: "कीमत (in Rs/)",
                                      enabled: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया कीमत दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FilledButton(
                                          onPressed: iWantToSell,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Text(
                                              "मैं बेचना चाहता हूँ",
                                              style: TextStyle(
                                                fontSize:
                                                    ResponsiveD.d(context) ==
                                                            ResponsiveD.desktop
                                                        ? 18
                                                        : 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                              const SizedBox(height: 20),
                              if (weightController.text.isNotEmpty &&
                                  valueController.text.isNotEmpty)
                                cusCard(
                                    child: FilledButton(
                                        onPressed: () {
                                          String price;
                                          double weight = double.parse(
                                              weightController.text.trim());
                                          price = priceCalculator(weight);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RecommendationPage(
                                                      price: price),
                                            ),
                                          );
                                        },
                                        child: const Text("Recommended Page")))
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: typeOfCalculator == CalculatorType.weight,
                        child: createResponsiveCalculatorPart(
                          left: Column(
                            children: [
                              chooseCalculatorTypeWidget,
                              const SizedBox(
                                height: 20,
                              ),
                              cusCard(
                                child: Column(
                                  children: [
                                    dropdownButtonFromFieldFunc(
                                      hintText: "पशु का प्रकार*",
                                      typeOfGoat: animalType,
                                      dataTypes: animalTypesList,
                                      onChanged: (v) {
                                        setState(() {
                                          animalType = v.toString();
                                        });
                                        if (weightController.text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            animalType != null &&
                                            faoScoreType != null) {
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु का प्रकार चुनें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    dropdownButtonFromFieldFunc(
                                      hintText: "पशु का लिंग (Gender)*",
                                      typeOfGoat: gender,
                                      dataTypes: genders,
                                      onChanged: (v) {
                                        setState(() {
                                          gender = v.toString();
                                        });
                                        if (weightController.text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            animalType != null &&
                                            faoScoreType != null) {
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु का लिंग चुनें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    textFormFieldFunc(
                                      controller: goatAgeController,
                                      keyboardType: TextInputType.number,
                                      labelText:
                                          "महीनों में पशु की उम्र (Age)*",
                                      hintText: "महीनों में पशु की उम्र",
                                      onChanged: (v) {
                                        if (weightController.text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            animalType != null &&
                                            faoScoreType != null) {
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु की उम्र दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          right: Column(
                            children: [
                              cusCard(
                                child: chooseBodyTypeForFOA(
                                  onChanged: (v) {
                                    setState(() {
                                      faoScoreType = v.toString();
                                    });
                                    if (weightController.text.isNotEmpty &&
                                        goatAgeController.text.isNotEmpty &&
                                        gender != null &&
                                        animalType != null &&
                                        faoScoreType != null) {
                                      valueController.text = priceCalculator(
                                          double.parse(weightController.text));
                                    } else {
                                      valueController.clear();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              cusCard(
                                child: Column(
                                  children: [
                                    textFormFieldFunc(
                                      controller: weightController,
                                      keyboardType: TextInputType.number,
                                      labelText: "वज़न (Weight)*",
                                      hintText: "वज़न (in kg)",
                                      onChanged: (v) {
                                        if (weightController.text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            animalType != null &&
                                            faoScoreType != null) {
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया वज़न दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    if (weightController.text.isNotEmpty &&
                                        valueController.text.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      textFormFieldFunc(
                                        controller: valueController,
                                        keyboardType: TextInputType.number,
                                        labelText: "कीमत (Value)",
                                        hintText: "कीमत (in Rs/)",
                                        enabled: false,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "कृपया कीमत दर्ज करें";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            child: FilledButton(
                                              onPressed: iWantToSell,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: Text(
                                                  "मैं बेचना चाहता हूँ",
                                                  style: TextStyle(
                                                    fontSize: ResponsiveD.d(
                                                                context) ==
                                                            ResponsiveD.desktop
                                                        ? 18
                                                        : 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: typeOfCalculator == CalculatorType.image,
                        child: createResponsiveCalculatorPart(
                          left: Column(
                            children: [
                              chooseCalculatorTypeWidget,
                              const SizedBox(
                                height: 20,
                              ),
                              cusCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CarouselSlider(
                                      options: CarouselOptions(autoPlay: true),
                                      items: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child:
                                              Image.asset("assets/image.jpg"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Image.asset(
                                              "assets/top-view.jpg"),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "वर्तमान में, यह विकासाधीन है। इसलिए इसका उपयोग केवल परीक्षण उद्देश्यों के लिए करें। इसे बेचने के लिए उपयोग न करें।",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                              type: FileType.image,
                                            );
                                            if (result != null) {
                                              setState(() {
                                                pickedFile = result.files.first;
                                              });
                                            }
                                          },
                                          icon: const Icon(Icons.image),
                                          label: const Text(
                                            "व्यक्ति के साथ पशु की छवि चुनें",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        pickedFile != null
                                            ? Text(
                                                pickedFile!.name,
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "संदर्भ व्यक्ति की लंबाई (Ex: 5 ft 6 inch)",
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: textFormFieldFunc(
                                            controller:
                                                referencePersonHeightFTController,
                                            keyboardType: TextInputType.number,
                                            labelText: "फुट*",
                                            hintText:
                                                "लंबाई फुट में डाले (Ex: 5)",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "कृपया लंबाई दर्ज करें";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: textFormFieldFunc(
                                            controller:
                                                referencePersonHeightInchController,
                                            keyboardType: TextInputType.number,
                                            labelText: "इंच*",
                                            hintText:
                                                "लंबाई इंच में डाले (Ex: 6)",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "कृपया लंबाई दर्ज करें";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          right: Column(
                            children: [
                              cusCard(
                                child: chooseBodyTypeForFOA(
                                  onChanged: (v) {
                                    setState(() {
                                      faoScoreType = v.toString();
                                    });
                                    if (referencePersonHeightInchController
                                            .text.isNotEmpty &&
                                        weightController.text.isNotEmpty &&
                                        goatAgeController.text.isNotEmpty &&
                                        gender != null &&
                                        pickedFile != null) {
                                      valueController.text = priceCalculator(
                                          double.parse(weightController.text));
                                    } else {
                                      valueController.clear();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              cusCard(
                                child: Column(
                                  children: [
                                    dropdownButtonFromFieldFunc(
                                      hintText: "पशु का प्रकार*",
                                      typeOfGoat: animalType,
                                      dataTypes: animalTypesList,
                                      onChanged: (v) {
                                        setState(() {
                                          animalType = v.toString();
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु का प्रकार चुनें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    dropdownButtonFromFieldFunc(
                                      hintText: "पशु का लिंग (Gender)*",
                                      typeOfGoat: gender,
                                      dataTypes: genders,
                                      onChanged: (v) {
                                        setState(() {
                                          gender = v.toString();
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु का लिंग चुनें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    textFormFieldFunc(
                                      controller: goatAgeController,
                                      keyboardType: TextInputType.number,
                                      labelText:
                                          "महीनों में पशु की उम्र (Age)*",
                                      hintText: "महीनों में पशु की उम्र",
                                      onChanged: (v) {
                                        if (referencePersonHeightInchController
                                                .text.isNotEmpty &&
                                            weightController.text.isNotEmpty &&
                                            goatAgeController.text.isNotEmpty &&
                                            gender != null &&
                                            pickedFile != null) {
                                          valueController.text =
                                              priceCalculator(double.parse(
                                                  weightController.text));
                                        } else {
                                          valueController.clear();
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया पशु की उम्र दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        showLoadingIndicator
                                            ? const SizedBox(
                                                width: 150,
                                                child:
                                                    LinearProgressIndicator())
                                            : FilledButton(
                                                onPressed: getWeightFromImage,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                    valueController.text.isEmpty
                                                        ? "वजन और मूल्य ज्ञात करें"
                                                        : "मूल्य की पुनर्गणना करें",
                                                    style: TextStyle(
                                                      fontSize: ResponsiveD.d(
                                                                  context) ==
                                                              ResponsiveD
                                                                  .desktop
                                                          ? 18
                                                          : 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (weightController.text.isNotEmpty &&
                                  valueController.text.isNotEmpty)
                                cusCard(
                                    child: Column(
                                  children: [
                                    textFormFieldFunc(
                                      controller: weightController,
                                      keyboardType: TextInputType.number,
                                      labelText: "वज़न (Weight)",
                                      hintText: "वज़न (in kg)",
                                      enabled: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया वज़न दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    textFormFieldFunc(
                                      controller: valueController,
                                      keyboardType: TextInputType.number,
                                      labelText: "कीमत (Value)",
                                      hintText: "कीमत (in Rs/)",
                                      enabled: false,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "कृपया कीमत दर्ज करें";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 25),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FilledButton(
                                          onPressed: iWantToSell,
                                          child:
                                              const Text("मैं बेचना चाहता हूँ"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: calculatorStep == CalculatorStep.formFill,
                child: Form(
                  key: _formKey,
                  child: createResponsiveCalculatorPart(
                    left: Column(
                      children: [
                        cusCard(
                            child: Column(
                          children: [
                            textFormFieldFunc(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              labelText: "वज़न (Weight)",
                              hintText: "वज़न (in kg)",
                              enabled: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "कृपया वज़न दर्ज करें";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            textFormFieldFunc(
                              controller: valueController,
                              keyboardType: TextInputType.number,
                              labelText: "कीमत (Value)",
                              hintText: "कीमत (in Rs/)",
                              enabled: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "कृपया कीमत दर्ज करें";
                                }
                                return null;
                              },
                            ),
                          ],
                        ))
                      ],
                    ),
                    right: Column(
                      children: [
                        cusCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   children: [
                              //     ElevatedButton.icon(
                              //       onPressed: () async {
                              //         FilePickerResult? result =
                              //             await FilePicker.platform.pickFiles(
                              //           type: FileType.image,
                              //         );
                              //         if (result != null) {
                              //           setState(() {
                              //             pickedFile = result.files.first;
                              //           });
                              //         }
                              //       },
                              //       icon: const Icon(Icons.image),
                              //       label: const Text(
                              //         "पशु के दांतों की छवि चुनें *",
                              //         style: TextStyle(
                              //           fontSize: 12,
                              //         ),
                              //       ),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     pickedFile != null
                              //         ? Text(
                              //             pickedFile!.name,
                              //           )
                              //         : const SizedBox()
                              //   ],
                              // ),
                              // if (showErrorTextImageNotFound)
                              //   if (pickedFile == null)
                              //     const Text(
                              //       "कृपया पशु के दांतों के चित्र संलग्न करें",
                              //       style: TextStyle(color: Colors.red),
                              //     ),
                              const SizedBox(height: 20),

                              textFormFieldFunc(
                                controller: farmerNameController,
                                keyboardType: TextInputType.name,
                                labelText: "किसान का नाम *",
                                hintText: "",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "कृपया नाम दर्ज करें";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              textFormFieldFunc(
                                controller: mobileNoController,
                                keyboardType: TextInputType.number,
                                labelText: "फ़ोन नंबर *",
                                hintText: "",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "कृपया फ़ोन नंबर दर्ज करें";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "किसान को भुगतान का तरीका*",
                                        style: TextStyle(
                                          fontSize: ResponsiveD.d(context) ==
                                                  ResponsiveD.desktop
                                              ? 18
                                              : 15,
                                        ),
                                      ),
                                      if (showErrorTextPaymentModeNotFound)
                                        const Text(
                                          "कृपया किसान को भुगतान का तरीका चुनें",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      for (Map item in paymentModeList)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: ChoiceChip(
                                            label: Text("${item["type"]}"),
                                            onSelected: (v) {
                                              setState(() {
                                                if (v == true) {
                                                  paymentMode.add(item["type"]);
                                                } else {
                                                  paymentMode
                                                      .remove(item["type"]);
                                                }
                                              });
                                            },
                                            selected: paymentMode
                                                .contains(item["type"]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              textFormFieldFunc(
                                controller: referralMobileNoController,
                                keyboardType: TextInputType.text,
                                labelText: "रेफरल मोबाइल नंबर",
                                hintText: "",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        cusCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "किसान का स्थान चुनें*",
                                        style: TextStyle(
                                          fontSize: ResponsiveD.d(context) ==
                                                  ResponsiveD.desktop
                                              ? 18
                                              : 15,
                                        ),
                                      ),
                                      if (showErrorTextLocationNotFound)
                                        const Text(
                                          "कृपया किसान का स्थान चुनें",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => chooseLocation(),
                                    icon: const Icon(Icons.edit, size: 15),
                                    label: const Text("Choose Location"),
                                  ),
                                ],
                              ),
                              if (selectedLocation != null) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: IframeView(
                                    source: selectedLocation != null
                                        ? "https://www.google.com/maps/embed/v1/place?key=$googleMapApiKeyConst&q=${selectedLocation!.latLng!.latitude},${selectedLocation!.latLng!.longitude}"
                                        : "https://www.google.com/maps/embed/v1/search?key=$googleMapApiKeyConst&q=india",
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              textFormFieldFunc(
                                controller: fullAddressController,
                                keyboardType: TextInputType.text,
                                labelText: "पूरा पता * (पिनकोड के साथ)",
                                hintText: "",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "कृपया पूरा पता दर्ज करें";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      launchUrlString(companyTNCUrl);
                                    },
                                    child: const Text(
                                      "नियम और शर्तें लागू*",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    onPressed: back,
                                    child: const Text("पीछे"),
                                  ),
                                  showLoadingIndicator
                                      ? const SizedBox(
                                          width: 100,
                                          child: LinearProgressIndicator())
                                      : FilledButton(
                                          onPressed: sellNow,
                                          child: const Text("अभी बेचें"),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: calculatorStep == CalculatorStep.submit,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        backgroundColor:
                            showLoadingIndicator ? Colors.blue : Colors.green,
                        radius: 40,
                        child: showLoadingIndicator
                            ? const CircularProgressIndicator()
                            : const Icon(
                                Icons.check,
                                size: 50,
                              ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        showLoadingIndicator
                            ? "कृपया प्रतीक्षा करें..."
                            : "धन्यवाद, हमारी टीम जल्द ही आपसे संपर्क करेगी।",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              ResponsiveD.d(context) == ResponsiveD.desktop
                                  ? 20
                                  : 18,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (!showLoadingIndicator)
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              calculatorStep = CalculatorStep.priceCalculate;
                            });
                          },
                          child: const Text("एक और पशु बेचो"),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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

  Widget createResponsiveCalculatorPart(
      {required Widget left, required Widget right}) {
    return ResponsiveD.d(context) == ResponsiveD.desktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: left,
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: right,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(
                height: 20,
              ),
              right,
            ],
          );
  }

  Widget dropdownButtonFromFieldFunc({
    required String? Function(String?)? validator,
    required String? typeOfGoat,
    required List<Map> dataTypes,
    required void Function(String?)? onChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: TextStyle(
            fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : 15,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        DropdownButtonFormField<String>(
          value: typeOfGoat,
          items: [
            for (var i = 0; i < dataTypes.length; i++)
              DropdownMenuItem(
                value: dataTypes[i]['type'],
                child: Text(
                  dataTypes[i]['type'],
                ),
              ),
          ],
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(
            fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            hintStyle: TextStyle(
              fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget chooseBodyTypeForFOA({
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "पशु के शरीर की स्तिथि चुनें*",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        for (Map bt in FAOBCSScoreList)
          RadioListTile<String>(
            groupValue: faoScoreType,
            value: bt['type'],
            onChanged: onChanged,
            title: Text(
              bt['title'],
              style: const TextStyle(),
            ),
            subtitle:
                faoScoreType == bt['type'] ? Image.asset(bt['img']) : null,
          )
      ],
    );
  }

  Widget textFormFieldFunc({
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required TextInputType keyboardType,
    required String labelText,
    required String hintText,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : 15,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 18 : 15,
            ),
            floatingLabelStyle: TextStyle(
              fontSize: ResponsiveD.d(context) == ResponsiveD.desktop ? 25 : 20,
              height: 0.01,
            ),
          ),
        ),
      ],
    );
  }
}

class CurrentPriceWidget extends StatefulWidget {
  const CurrentPriceWidget({
    super.key,
  });
  @override
  State<CurrentPriceWidget> createState() => _CurrentPriceWidgetState();
}

class _CurrentPriceWidgetState extends State<CurrentPriceWidget> {
  String imagePath = "assets/goat_icon.png";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 25.0,
              fontFamily: 'Horizon',
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                for (Map animal in animalTypesList)
                  RotateAnimatedText('${animal['price']}Rs/kg'),
              ],
              onNext: (int index, bool isLast) {
                imagePath = index == 1
                    ? "assets/goat_icon.png"
                    : "assets/sheep_icon.png";
                setState(() {});
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          CircleAvatar(
            radius: 22,
            child: Image.asset(
              imagePath,
            ),
          ),
        ],
      ),
    );
  }
}
