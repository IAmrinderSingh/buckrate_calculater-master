import 'package:flutter/material.dart';

class CustomStepper extends StatefulWidget {
  const CustomStepper({super.key});

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int _currentStep = 0;

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
  };

  // Data options
  final List<String> colors = ['Black', 'White', 'Tan'];
  final List<String> densities = ['Low', 'Medium', 'High', 'No Spot'];
  final List<String> distributions = [
    'Evenly Distributed',
    'Non Evenly Distributed'
  ];
  final List<String> booleansList = ['Yes', 'No'];
  final List<String> breedList = ['Mix', 'Pure'];
  final List<String> hornsList = [
    'Round and Small',
    'Round and Medium',
    'Round and Large',
    'Straight and Small',
    'Straight and Medium',
    'Straight and Large',
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep <= 4 ? _onStepContinue : null,
        onStepCancel: _currentStep > 0 ? _onStepCancel : null,
        steps: _buildSteps(isMobile),
        type: StepperType.vertical,
      ),
    );
  }

  // Build steps dynamically
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
            densities,
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
        content: isMobile
            ? Column(children: _buildOtherDropDowns())
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildOtherDropDowns(),
              ),
        isActive: _currentStep >= 4,
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
        // _completeStepper();
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
    Navigator.of(context).pop(); // Close the stepper
  }

  // Validation logic
  bool _validateCurrentStep() {
    final keysToValidate = [
      ['bodyColor', 'neckColor', 'faceColor', 'legColor'],
      ['bodySpotColor', 'neckSpotColor', 'faceSpotColor', 'legSpotColor'],
      ['bodySpotSize', 'neckSpotSize', 'faceSpotSize', 'legSpotSize'],
      ['bodyDensity', 'neckDensity', 'faceDensity', 'legDensity'],
      [
        'bodyDistribution',
        'neckDistribution',
        'faceDistribution',
        'legDistribution'
      ],
      ['bodyShine', 'specialMarks', 'breed', 'horns']
    ];

    if (_currentStep < keysToValidate.length) {
      return keysToValidate[_currentStep]
          .every((key) => selections[key] != null);
    }
    return true;
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Please complete all selections in this step.')),
    );
  }
}
