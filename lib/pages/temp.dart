double calculateValue() {
  double value = 0.0;

  // Get values from selections map
  String? neckColor = selections['neckColor'] ?? '';
  String? faceColor = selections['faceColor'] ?? '';
  String? faceSpotColor = selections['faceSpotColor'] ?? '';
  String? faceSpotSize = selections['faceSpotSize'] ?? '';
  String? faceDensity = selections['faceDensity'] ?? '';
  String? faceDistribution = selections['faceDistribution'] ?? '';

  // Calculate based on faceColor
  if (faceColor == "Tan") {
    value += _calculateTan(
        neckColor, faceSpotColor, faceSpotSize, faceDensity, faceDistribution);
  } else if (faceColor == "Black") {
    value += _calculateBlack(
        neckColor, faceSpotColor, faceSpotSize, faceDensity, faceDistribution);
  } else if (faceColor == "White") {
    value += _calculateWhite(
        neckColor, faceSpotColor, faceSpotSize, faceDensity, faceDistribution);
  }

  return value;
}

double _calculateTan(
  String? neckColor,
  String? faceSpotColor,
  String? faceSpotSize,
  String? faceDensity,
  String? faceDistribution,
) {
  double value = 1.01;

  // Calculate based on neckColor
  if (neckColor == "White") value += 0.005;
  if (neckColor == "Black") value += 0.002;

  // Calculate based on faceSpotColor
  if (faceSpotColor == "White") value += 0.005;
  if (faceSpotColor == "Black") value += 0.001;
  if (faceSpotColor == "No Spot") value += 0.0025;

  // Calculate based on faceSpotSize
  value += _calculateFaceSpotSize(faceSpotSize, faceDensity, faceDistribution);

  return value;
}

double _calculateBlack(
  String? neckColor,
  String? faceSpotColor,
  String? faceSpotSize,
  String? faceDensity,
  String? faceDistribution,
) {
  double value = 1.01;

  // Calculate based on neckColor
  if (neckColor == "White") value += 0.005;
  if (neckColor == "Tan") value += 0.002;

  // Calculate based on faceSpotColor
  if (faceSpotColor == "White") value += 0.005;
  if (faceSpotColor == "Black") value += 0.001;
  if (faceSpotColor == "No Spot") value += 0.0025;

  // Calculate based on faceSpotSize
  value += _calculateFaceSpotSize(faceSpotSize, faceDensity, faceDistribution);

  return value;
}

double _calculateWhite(
  String? neckColor,
  String? faceSpotColor,
  String? faceSpotSize,
  String? faceDensity,
  String? faceDistribution,
) {
  double value = 1.01;

  // Calculate based on neckColor
  if (neckColor == "Tan") value += 0.005;
  if (neckColor == "Black") value += 0.002;

  // Calculate based on faceSpotColor
  if (faceSpotColor == "White") value += 0.005;
  if (faceSpotColor == "Black") value += 0.001;
  if (faceSpotColor == "No Spot") value += 0.0025;

  // Calculate based on faceSpotSize
  value += _calculateFaceSpotSize(faceSpotSize, faceDensity, faceDistribution);

  return value;
}

double _calculateFaceSpotSize(
  String? faceSpotSize,
  String? faceDensity,
  String? faceDistribution,
) {
  double value = 0.0;

  // Handle the different faceSpotSize cases
  if (faceSpotSize == "<=1 cm") {
    value += _getFaceDensityValue(faceDensity);
    value += _getFaceDistributionValue(faceDistribution, 0.001, -0.001);
  } else if (faceSpotSize == "> 1 cm & <=3 cm") {
    value += _getFaceDensityValue(faceDensity, medium: 0.003, low: 0.006);
    value += _getFaceDistributionValue(faceDistribution, 0.001, -0.001);
  } else if (faceSpotSize == ">3 cm & <= 5 cm") {
    value += _getFaceDensityValue(faceDensity, medium: 0.0015, low: 0.003);
    value += _getFaceDistributionValue(faceDistribution, 0.001, -0.001);
  } else if (faceSpotSize == "> 5 cm") {
    value += _getFaceDensityValue(faceDensity, medium: -0.0005, low: 0.0005);
    value += _getFaceDistributionValue(faceDistribution, 0, -0.001);
  }

  return value;
}

double _getFaceDensityValue(String? faceDensity,
    {double high = 0.0025, double medium = 0.003, double low = 0.005}) {
  if (faceDensity == "High") return -0.001;
  if (faceDensity == "Medium") return medium;
  if (faceDensity == "Low") return low;
  return 0.0;
}

double _getFaceDistributionValue(
    String? faceDistribution, double evenlyValue, double nonEvenlyValue) {
  return (faceDistribution == "Evenly Distributed")
      ? evenlyValue
      : nonEvenlyValue;
}
