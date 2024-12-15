class AnimalDataModel {
  List<Data>? data;
  String? status;

  AnimalDataModel({this.data, this.status});

  AnimalDataModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    return data;
  }
}

class Data {
  double? addedTime;
  double? cattleAge;
  String? cattleGender;
  List? cattleImage;
  int? cattlePrice;
  String? cattleType;
  List? cattleVideo;
  double? cattleWeight;
  String? fAOBCSScore;
  String? farmerMobile;
  String? farmerName;
  String? fullAddress;
  Location? location;
  List<String>? paymentMode;
  String? refralMobile;
  int? saleStatus;
  Null updatedTime;
  String? sId;

  Data(
      {this.addedTime,
      this.cattleAge,
      this.cattleGender,
      this.cattleImage,
      this.cattlePrice,
      this.cattleType,
      this.cattleVideo,
      this.cattleWeight,
      this.fAOBCSScore,
      this.farmerMobile,
      this.farmerName,
      this.fullAddress,
      this.location,
      this.paymentMode,
      this.refralMobile,
      this.saleStatus,
      this.updatedTime,
      this.sId});

  Data.fromJson(Map<String, dynamic> json) {
    addedTime = json['Added_time'];
    cattleAge = json['Cattle_age'];
    cattleGender = json['Cattle_gender'];
    if (json['Cattle_image'] != null) {
      cattleImage = <Null>[];
      json['Cattle_image'].forEach((v) {
        cattleImage!.add(v);
      });
    }
    cattlePrice = json['Cattle_price'];
    cattleType = json['Cattle_type'];
    if (json['Cattle_video'] != null) {
      cattleVideo = <Null>[];
      json['Cattle_video'].forEach((v) {
        cattleVideo!.add(v);
      });
    }
    cattleWeight = json['Cattle_weight'];
    fAOBCSScore = json['FAOBCS_score'];
    farmerMobile = json['Farmer_mobile'];
    farmerName = json['Farmer_name'];
    fullAddress = json['Full_address'];
    location =
        json['Location'] != null ? Location.fromJson(json['Location']) : null;
    paymentMode = json['Payment_mode'].cast<String>();
    refralMobile = json['Refral_mobile'];
    saleStatus = json['Sale_status'];
    updatedTime = json['Updated_time'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Added_time'] = addedTime;
    data['Cattle_age'] = cattleAge;
    data['Cattle_gender'] = cattleGender;
    if (cattleImage != null) {
      data['Cattle_image'] = cattleImage!.map((v) => v.toJson()).toList();
    }
    data['Cattle_price'] = cattlePrice;
    data['Cattle_type'] = cattleType;
    if (cattleVideo != null) {
      data['Cattle_video'] = cattleVideo!.map((v) => v.toJson()).toList();
    }
    data['Cattle_weight'] = cattleWeight;
    data['FAOBCS_score'] = fAOBCSScore;
    data['Farmer_mobile'] = farmerMobile;
    data['Farmer_name'] = farmerName;
    data['Full_address'] = fullAddress;
    if (location != null) {
      data['Location'] = location!.toJson();
    }
    data['Payment_mode'] = paymentMode;
    data['Refral_mobile'] = refralMobile;
    data['Sale_status'] = saleStatus;
    data['Updated_time'] = updatedTime;
    data['_id'] = sId;
    return data;
  }
}

class Location {
  List? coordinates;
  String? type;

  Location({this.coordinates, this.type});

  Location.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coordinates'] = coordinates;
    data['type'] = type;
    return data;
  }
}
