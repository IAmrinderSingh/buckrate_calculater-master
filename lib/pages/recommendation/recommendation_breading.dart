import 'package:flutter/material.dart';

class RecommendationPage extends StatefulWidget {
  static const String routeName = "/recommendation";
  static const String routePath = "/recommendation/:price";
  final String price;
  const RecommendationPage({super.key, required this.price});
  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  int _currentStep = 0;
  double initialPrice = 0;
  double price = 0;

  @override
  void initState() {
    super.initState();
    initialPrice = double.parse(widget.price);
    price = double.parse(widget.price);
  }

  // Selection data stored in a Map
  final Map<String, String?> selections = {
    'bodyColor': null,
    'neckColor': null,
    'faceColor': null,
    'legColor': null,
    'bodySpotColor': null,
    'neckSpotColor': null,
    'faceSpotColor': null,
    'legSpotColor': null,
    'bodySpotSize': null,
    'neckSpotSize': null,
    'faceSpotSize': null,
    'legSpotSize': null,
    'bodyDensity': null,
    'neckDensity': null,
    'faceDensity': null,
    'legDensity': null,
    'bodyDistribution': null,
    'neckDistribution': null,
    'faceDistribution': null,
    'legDistribution': null,
    'bodyShine': null,
    'specialMarks': null,
    'breed': null,
    'horns': null,
    'earLength': null,
  };

  // Data options
  final List<String> colors = ['Black', 'White', 'Tan'];
  final List<String> densities = ['Low', 'Medium', 'High', 'No Spot'];
  final List<String> spots = [
    '<= 1cm',
    '> 1cm & <= 3cm',
    '> 3cm & <= 5cm',
    '> 5cm'
  ];
  final List<String> distributions = [
    'Evenly Distributed',
    'Non Evenly Distributed'
  ];
  final List<String> booleansList = ['Yes', 'No'];
  final List<String> breedList = ['Mix', 'Pure'];
  final List<String> hornsList = [
    'Round and Small (<5cm)',
    'Round and Medium (5-10cm)',
    'Round and Large (>10cm)',
    'Straight and Small (<5cm)',
    'Straight and Medium (5-10cm)',
    'Straight and Large (>10cm)',
  ];

  final List<String> earLengthList = ['Normal', 'Medium', 'Large', 'No Ears'];

  double applyCondition(bool condition, double value) {
    return condition ? value : 0;
  }

  double calculateBodyPrice() {
    double price = 1.01;

    // Helper function for spot size and its nested conditions
    double calculateSpotAdjustment(
        String? size, String? density, String? distribution) {
      double adjustment = 0.0;
      if (size == "<= 1cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment += 0.0025;
        if (density == "Low") adjustment += 0.005;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 1cm & <= 3cm") {
        if (density == "High") adjustment += 0.001;
        if (density == "Medium") adjustment += 0.003;
        if (density == "Low") adjustment += 0.006;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 3cm & <= 5cm") {
        if (density == "High") adjustment += 0.0005;
        if (density == "Medium") adjustment += 0.0015;
        if (density == "Low") adjustment += 0.003;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 5cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment -= 0.0005;
        if (density == "Low") adjustment += 0.0005;
        adjustment += (distribution == "Evenly Distributed") ? 0 : -0.001;
      }
      return adjustment;
    }

    // Calculate adjustments for bodyColor = "Tan"
    if (selections['bodyColor'] == "Tan") {
      price += (selections['neckColor'] == "White" ? 0.038 : 0) +
          (selections['legColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Black" ? 0.002 : 0) +
          (selections['legColor'] == "Black" ? 0.002 : 0) +
          (selections['bodySpotColor'] == "White" ? 0.005 : 0) +
          (selections['bodySpotColor'] == "Black" ? 0.001 : 0) +
          (selections['bodySpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['bodySpotSize'],
              selections['bodyDensity'], selections['bodyDistribution']);
    }

    // Calculate adjustments for bodyColor = "Black"
    if (selections['bodyColor'] == "Black") {
      price += (selections['neckColor'] == "White" ? 0.038 : 0) +
          (selections['legColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Tan" ? 0.002 : 0) +
          (selections['legColor'] == "Tan" ? 0.002 : 0) +
          (selections['bodySpotColor'] == "White" ? 0.005 : 0) +
          (selections['bodySpotColor'] == "Tan" ? 0.001 : 0) +
          (selections['bodySpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['bodySpotSize'],
              selections['bodyDensity'], selections['bodyDistribution']);
    }

    // Calculate adjustments for bodyColor = "White"
    if (selections['bodyColor'] == "White") {
      price += (selections['neckColor'] == "Black" ? 0.038 : 0) +
          (selections['legColor'] == "Black" ? 0.005 : 0) +
          (selections['neckColor'] == "Tan" ? 0.002 : 0) +
          (selections['legColor'] == "Tan" ? 0.002 : 0) +
          (selections['bodySpotColor'] == "Black" ? 0.005 : 0) +
          (selections['bodySpotColor'] == "Tan" ? 0.001 : 0) +
          (selections['bodySpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['bodySpotSize'],
              selections['bodyDensity'], selections['bodyDistribution']);
    }
    print(price);
    return price;
  }

  double calculateNeckPrice() {
    double price = 1.01;

    // Helper function for spot size and its nested conditions
    double calculateSpotAdjustment(
        String? size, String? density, String? distribution) {
      double adjustment = 0.0;
      if (size == "<= 1cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment += 0.0025;
        if (density == "Low") adjustment += 0.005;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 1cm & <= 3cm") {
        if (density == "High") adjustment += 0.001;
        if (density == "Medium") adjustment += 0.003;
        if (density == "Low") adjustment += 0.006;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 3cm & <= 5cm") {
        if (density == "High") adjustment += 0.0005;
        if (density == "Medium") adjustment += 0.0015;
        if (density == "Low") adjustment += 0.003;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 5cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment -= 0.0005;
        if (density == "Low") adjustment += 0.0005;
        adjustment += (distribution == "Evenly Distributed") ? 0 : -0.001;
      }
      return adjustment;
    }

    // Calculate adjustments for bodyColor = "Tan"
    if (selections['bodyColor'] == "Tan") {
      price += (selections['neckColor'] == "White" ? 0.038 : 0) +
          (selections['faceColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Black" ? 0.002 : 0) +
          (selections['faceColor'] == "Black" ? 0.002 : 0) +
          (selections['neckSpotColor'] == "White" ? 0.005 : 0) +
          (selections['neckSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['neckSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['neckSpotSize'],
              selections['neckDensity'], selections['neckDistribution']);
    }

    // Calculate adjustments for bodyColor = "Black"
    if (selections['bodyColor'] == "Black") {
      price += (selections['neckColor'] == "White" ? 0.038 : 0) +
          (selections['faceColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Tan" ? 0.002 : 0) +
          (selections['faceColor'] == "Tan" ? 0.002 : 0) +
          (selections['neckSpotColor'] == "White" ? 0.005 : 0) +
          (selections['neckSpotColor'] == "Tan" ? 0.001 : 0) +
          (selections['neckSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['neckSpotSize'],
              selections['neckDensity'], selections['neckDistribution']);
    }

    // Calculate adjustments for bodyColor = "White"
    if (selections['bodyColor'] == "White") {
      price += (selections['neckColor'] == "Black" ? 0.038 : 0) +
          (selections['faceColor'] == "Black" ? 0.005 : 0) +
          (selections['neckColor'] == "Tan" ? 0.002 : 0) +
          (selections['faceColor'] == "Tan" ? 0.002 : 0) +
          (selections['neckSpotColor'] == "Black" ? 0.005 : 0) +
          (selections['neckSpotColor'] == "Tan" ? 0.001 : 0) +
          (selections['neckSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['neckSpotSize'],
              selections['neckDensity'], selections['neckDistribution']);
    }

    // Return the calculated price
    print("Calculated price: $price");
    return price;
  }

  double calculateFacePrice() {
    double price = 1.01;
    double calculateSpotAdjustment(
        String? size, String? density, String? distribution) {
      double adjustment = 0.0;

      if (size == "<= 1cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment += 0.0025;
        if (density == "Low") adjustment += 0.005;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 1cm & <= 3cm") {
        if (density == "High") adjustment += 0.001;
        if (density == "Medium") adjustment += 0.003;
        if (density == "Low") adjustment += 0.006;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 3cm & <= 5cm") {
        if (density == "High") adjustment += 0.0005;
        if (density == "Medium") adjustment += 0.0015;
        if (density == "Low") adjustment += 0.003;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 5cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment -= 0.0005;
        if (density == "Low") adjustment += 0.0005;
        adjustment += (distribution == "Evenly Distributed") ? 0 : -0.001;
      }

      return adjustment;
    }

    // Adjustments for faceColor = "Tan"
    if (selections['faceColor'] == "Tan") {
      price += (selections['neckColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Black" ? 0.002 : 0) +
          (selections['faceSpotColor'] == "White" ? 0.005 : 0) +
          (selections['faceSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['faceSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['faceSpotSize'],
              selections['faceDensity'], selections['faceDistribution']);
    }

    // Adjustments for faceColor = "Black"
    if (selections['faceColor'] == "Black") {
      price += (selections['neckColor'] == "White" ? 0.005 : 0) +
          (selections['neckColor'] == "Tan" ? 0.002 : 0) +
          (selections['faceSpotColor'] == "White" ? 0.005 : 0) +
          (selections['faceSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['faceSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['faceSpotSize'],
              selections['faceDensity'], selections['faceDistribution']);
    }

    // Adjustments for faceColor = "White"
    if (selections['faceColor'] == "White") {
      price += (selections['neckColor'] == "Tan" ? 0.005 : 0) +
          (selections['neckColor'] == "Black" ? 0.002 : 0) +
          (selections['faceSpotColor'] == "White" ? 0.005 : 0) +
          (selections['faceSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['faceSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['faceSpotSize'],
              selections['faceDensity'], selections['faceDistribution']);

      print(calculateSpotAdjustment(selections['faceSpotSize'],
          selections['faceDensity'], selections['faceDistribution']));
    }

    // Return the calculated price
    print("Calculated price: $price");
    return price;
  }

  double calculateLegPrice() {
    double price = 1.01;
    double calculateSpotAdjustment(
        String? size, String? density, String? distribution) {
      double adjustment = 0.0;

      if (size == "<= 1cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment += 0.0025;
        if (density == "Low") adjustment += 0.005;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 1cm & <= 3cm") {
        if (density == "High") adjustment += 0.001;
        if (density == "Medium") adjustment += 0.003;
        if (density == "Low") adjustment += 0.006;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 3cm & <= 5cm") {
        if (density == "High") adjustment += 0.0005;
        if (density == "Medium") adjustment += 0.0015;
        if (density == "Low") adjustment += 0.003;
        adjustment += (distribution == "Evenly Distributed") ? 0.001 : -0.001;
      } else if (size == "> 5cm") {
        if (density == "High") adjustment -= 0.001;
        if (density == "Medium") adjustment -= 0.0005;
        if (density == "Low") adjustment += 0.0005;
        adjustment += (distribution == "Evenly Distributed") ? 0 : -0.001;
      }

      return adjustment;
    }

    // Adjustments for legColor = "Tan"
    if (selections['legColor'] == "Tan") {
      price += (selections['bodyColor'] == "White" ? 0.005 : 0) +
          (selections['bodyColor'] == "Black" ? 0.002 : 0) +
          (selections['legSpotColor'] == "White" ? 0.005 : 0) +
          (selections['legSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['legSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['legSpotSize'],
              selections['legDensity'], selections['legDistribution']);
    }

    // Adjustments for legColor = "Black"
    if (selections['legColor'] == "Black") {
      price += (selections['bodyColor'] == "White" ? 0.005 : 0) +
          (selections['bodyColor'] == "Tan" ? 0.002 : 0) +
          (selections['legSpotColor'] == "White" ? 0.005 : 0) +
          (selections['legSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['legSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['legSpotSize'],
              selections['legDensity'], selections['legDistribution']);

      print(calculateSpotAdjustment(selections['legSpotSize'],
          selections['legDensity'], selections['legDistribution']));
    }

    // Adjustments for legColor = "White"
    if (selections['legColor'] == "White") {
      price += (selections['bodyColor'] == "Tan" ? 0.005 : 0) +
          (selections['bodyColor'] == "Black" ? 0.002 : 0) +
          (selections['legSpotColor'] == "White" ? 0.005 : 0) +
          (selections['legSpotColor'] == "Black" ? 0.001 : 0) +
          (selections['legSpotColor'] == "No Spot" ? 0.0025 : 0) +
          calculateSpotAdjustment(selections['legSpotSize'],
              selections['legDensity'], selections['legDistribution']);
    }

    // Return the calculated price
    print("Calculated price: $price");
    return price;
  }

  double calculateOtherFactorPrice() {
    double price = 0;

    if (selections['bodyShine'] == 'Yes') {
      price += 1.02;
    }
    if (selections['specialMarks'] == 'Yes') {
      price += 1.1;
    }
    if (selections['breed'] == 'Pure') {
      price += 1.1;
    }
    if (selections['horns'] == 'Round and Small (<5cm)') {
      price += 1.01;
    } else if (selections['horns'] == 'Round and Medium (5-10cm)') {
      price += 1.02;
    } else if (selections['horns'] == 'Round and Large (>10cm)') {
      price += 1.005;
    } else if (selections['horns'] == 'Straight and Small (<5cm)') {
      price += 1.01;
    } else if (selections['horns'] == 'Straight and Small (<5cm)') {
      price += 1.005;
    } else {
      price -= 1.01;
    }

    return price;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // width: MediaQuery.of(context).size.width,
                            child: Text("Initial Price: $initialPrice"),
                          ),
                          SizedBox(
                            // width: MediaQuery.of(context).size.width,
                            child: Text("Current Price: $price"),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Stepper(
                          currentStep: _currentStep,
                          onStepContinue:
                              _currentStep <= 5 ? _onStepContinue : null,
                          onStepCancel: _currentStep > 0 ? _onStepCancel : null,
                          steps: _buildSteps(isMobile),
                          type: StepperType.vertical,
                        ),
                      )
                    ]))));
  }

  List<Step> _buildSteps(bool isMobile) {
    return [
      _stepTemplate(
        title: 'Select Buck Colors',
        content: _buildDropDownList(
            ['bodyColor', 'neckColor', 'faceColor', 'legColor'],
            colors,
            isMobile),
      ),
      _stepTemplate(
        title: 'Select Spot Colors',
        content: _buildDropDownList(
            ['bodySpotColor', 'neckSpotColor', 'faceSpotColor', 'legSpotColor'],
            colors,
            isMobile),
      ),
      _stepTemplate(
        title: 'Select Spot Size',
        content: _buildDropDownList(
            ['bodySpotSize', 'neckSpotSize', 'faceSpotSize', 'legSpotSize'],
            spots,
            isMobile),
      ),
      _stepTemplate(
        title: 'Select Spot Density',
        content: _buildDropDownList(
            ['bodyDensity', 'neckDensity', 'faceDensity', 'legDensity'],
            densities,
            isMobile),
      ),
      _stepTemplate(
        title: 'Select Spot Distribution',
        content: _buildDropDownList([
          'bodyDistribution',
          'neckDistribution',
          'faceDistribution',
          'legDistribution'
        ], distributions, isMobile),
      ),
      Step(
        title: const Text('Final Selections'),
        content: Column(
          children: [
            isMobile
                ? Column(children: _buildOtherDropDowns())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildOtherDropDowns(),
                  ),
            SizedBox(
              width: 200,
              child: _buildDropDownList(['EarLength'], earLengthList, isMobile),
            )
          ],
        ),
        isActive: _currentStep >= 0,
      ),
    ];
  }

  // Template for steps
  Step _stepTemplate({required String title, required Widget content}) {
    return Step(
      title: Text(title),
      content: content,
      isActive: _currentStep >= 0,
    );
  }

  // Build dropdowns for keys
  Widget _buildDropDownList(
      List<String> keys, List<String> options, bool isMobile) {
    return isMobile
        ? Column(
            children: keys.map((key) => _buildDropDown(key, options)).toList())
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: keys
                .map((key) => Expanded(child: _buildDropDown(key, options)))
                .toList(),
          );
  }

  // Build individual dropdown
  Widget _buildDropDown(String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selections[key],
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selections[key] = value;
          });
        },
        decoration: InputDecoration(
          labelText: _capitalize(key),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Build dropdowns for final step
  List<Widget> _buildOtherDropDowns() {
    final List<Map<String, dynamic>> finalStepOptions = [
      {'key': 'bodyShine', 'label': 'Body Shine', 'options': booleansList},
      {
        'key': 'specialMarks',
        'label': 'Special Marks',
        'options': booleansList
      },
      {'key': 'breed', 'label': 'Breed', 'options': breedList},
      {'key': 'horns', 'label': 'Horns', 'options': hornsList},
      // {'key': 'earLength', 'label': 'Ear Length', 'options': earLengthList},
    ];

    return finalStepOptions
        .map(
          (entry) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildDropDown(entry['key'], entry['options']),
            ),
          ),
        )
        .toList();
  }

  // Capitalize string with spacing for camelCase
  String _capitalize(String text) {
    return text
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}')
        .replaceFirst(text[0], text[0].toUpperCase());
  }

  // Stepper control methods
  void _onStepContinue() {
    if (_validateCurrentStep()) {
      if (_currentStep < 5) {
        // Move to the next step
        setState(() {
          _currentStep++;
        });
      } else {
        // Final step completed
        _completeStepper();
      }
    } else {
      _showValidationError();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _completeStepper() {
    // Perform any additional actions here if needed (e.g., saving data)
    // Navigator.of(context).pop(); // Close the stepper
    // print('price $initialPrice,$calculatePrice()');
    setState(() {
      price = initialPrice *
          calculateBodyPrice() *
          calculateNeckPrice() *
          calculateFacePrice() *
          calculateLegPrice() *
          calculateOtherFactorPrice();
    });
  }

  // Validation logic
  bool _validateCurrentStep() {
    // final keysToValidate = [
    //   ['bodyColor', 'neckColor', 'faceColor', 'legColor'],
    //   ['bodySpotColor', 'neckSpotColor', 'faceSpotColor', 'legSpotColor'],
    //   ['bodySpotSize', 'neckSpotSize', 'faceSpotSize', 'legSpotSize'],
    //   ['bodyDensity', 'neckDensity', 'faceDensity', 'legDensity'],
    //   [
    //     'bodyDistribution',
    //     'neckDistribution',
    //     'faceDistribution',
    //     'legDistribution'
    //   ],
    //   ['bodyShine', 'specialMarks', 'breed', 'horns']
    // ];

    // if (_currentStep < keysToValidate.length) {
    //   return keysToValidate[_currentStep]
    //       .every((key) => selections[key] != null);
    // }
    return true;
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Please complete all selections in this step.')),
    );
  }
}
