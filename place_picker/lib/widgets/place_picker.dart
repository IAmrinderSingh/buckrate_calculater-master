import 'dart:async';
import 'dart:convert';
import 'dart:developer' as d;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:place_picker/entities/entities.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/widgets/widgets.dart';

import '../uuid.dart';

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
// ignore: must_be_immutable
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  final String apiKey;
  final String apiBaseUrl;
  final bool showNearByPlaces;
  final Color? appBarBackgroundColor;

  /// Location to be displayed when screen is showed. If this is set or not null, the
  /// map does not pan to the user's current location.
  final LatLng? displayLocation;
  LocalizationItem? localizationItem;
  LatLng defaultLocation = const LatLng(10.5381264, 73.8827201);

  PlacePicker(this.apiKey, this.apiBaseUrl,
      {this.displayLocation,
      this.localizationItem,
      this.appBarBackgroundColor,
      this.showNearByPlaces = true,
      LatLng? defaultLocation}) {
    if (this.localizationItem == null) {
      this.localizationItem = new LocalizationItem();
    }
    if (defaultLocation != null) {
      this.defaultLocation = defaultLocation;
    }
  }

  @override
  State<StatefulWidget> createState() => PlacePickerState();
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  final Completer<GoogleMapController> mapController = Completer();
  LatLng? _currentLocation;
  bool _loadMap = false;

  /// Indicator for the selected location
  final Set<Marker> markers = Set();

  /// Result returned after user completes selection
  LocationResult? locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry? overlayEntry;

  List<NearbyPlace> nearbyPlaces = [];

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  // constructor
  // PlacePickerState();

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.displayLocation == null) {
      getCurrentLocation().then((value) {
        if (value != null) {
          setState(() {
            _currentLocation = value;
          });
        } else {
          //Navigator.of(context).pop(null);
          print("getting current location null");
        }
        setState(() {
          _loadMap = true;
        });
      }).catchError((e) {
        if (e is LocationServiceDisabledException) {
          Navigator.of(context).pop(null);
        } else {
          setState(() {
            _loadMap = true;
          });
        }
        print(e);
        //Navigator.of(context).pop(null);
      });
    } else {
      setState(() {
        markers.add(Marker(
          position: widget.displayLocation!,
          markerId: const MarkerId("selected-location"),
        ));
        _loadMap = true;
      });
    }
  }

  @override
  void dispose() {
    this.overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bottomBar = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SelectPlaceAction(getLocationName(), () {
          if (!kIsWeb) {
            if (Platform.isAndroid) {
              _delayedPop();
              return;
            }
          }
          Navigator.of(context).pop(this.locationResult);
        }, widget.localizationItem!.tapToSelectLocation),
        if (widget.showNearByPlaces) ...[
          const Divider(height: 8),
          Padding(
            child: Text(widget.localizationItem!.nearBy,
                style: const TextStyle(fontSize: 16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          Expanded(
            child: ListView(
              children: nearbyPlaces
                  .map((it) => NearbyPlaceItem(it, () {
                        if (it.latLng != null) {
                          moveToLocation(it.latLng!);
                        }
                      }))
                  .toList(),
            ),
          ),
        ]
      ],
    );
    return WillPopScope(
      onWillPop: () {
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            locationResult = null;
            _delayedPop();
            return Future.value(false);
          }
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.appBarBackgroundColor,
          key: this.appBarKey,
          title: SearchInput(searchPlace),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: !_loadMap
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.displayLocation ??
                            _currentLocation ??
                            widget.defaultLocation,
                        zoom: _currentLocation == null &&
                                widget.displayLocation == null
                            ? 5
                            : 15,
                      ),
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      buildingsEnabled: false,
                      onMapCreated: onMapCreated,
                      onTap: (latLng) {
                        clearOverlay();
                        moveToLocation(latLng);
                      },
                      markers: markers,
                    ),
            ),
            // if (!this.hasSearchTerm)
            widget.showNearByPlaces
                ? Expanded(
                    child: bottomBar,
                  )
                : bottomBar,
          ],
        ),
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (this.overlayEntry != null) {
      this.overlayEntry?.remove();
      this.overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == this.previousSearchTerm) {
      return;
    }

    previousSearchTerm = place;

    clearOverlay();

    setState(() {
      hasSearchTerm = place.length > 0;
    });

    if (place.length < 1) {
      return;
    }

    // final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    final RenderBox? appBarBox =
        this.appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final size = appBarBox?.size;

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // top: appBarBox?.size.height,
        left: appBarBox?.localToGlobal(Offset.zero).dx,
        top: appBarBox!.localToGlobal(Offset.zero).dy + 50,
        width: size?.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: <Widget>[
                const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3)),
                const SizedBox(width: 24),
                Expanded(
                    child: Text(widget.localizationItem!.findingPlace,
                        style: const TextStyle(fontSize: 16)))
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry!);

    autoCompleteSearch(place);
  }

  Future<List<dynamic>> searchPlaceRepo(
      String apiBaseUrl, String place, LatLng latLng) async {
    var endpoint =
        "${apiBaseUrl}/gmapsearch/place/$place/${latLng.latitude}/${latLng.longitude}";

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode != 200) {
      throw Error();
    }

    final responseJson = jsonDecode(response.body);

    if (responseJson['predictions'] == null) {
      throw Error();
    }

    List<dynamic> predictions = responseJson['predictions'];
    return predictions;
  }

  /// Fetches the place autocomplete list with the query [place].
  Future<void> autoCompleteSearch(String place) async {
    try {
      place = place.replaceAll(" ", "+");
      List<dynamic> predictions = await searchPlaceRepo(
          widget.apiBaseUrl,
          place,
          LatLng(this.locationResult!.latLng!.latitude,
              this.locationResult!.latLng!.longitude));

      List<RichSuggestion> suggestions = [];

      if (predictions.isEmpty) {
        AutoCompleteItem aci = AutoCompleteItem();
        aci.text = widget.localizationItem!.noResultsFound;
        aci.offset = 0;
        aci.length = 0;

        suggestions.add(RichSuggestion(aci, () {}));
      } else {
        for (dynamic t in predictions) {
          final aci = AutoCompleteItem()
            ..id = t['place_id']
            ..text = t['description']
            ..offset = t['matched_substrings'][0]['offset']
            ..length = t['matched_substrings'][0]['length'];

          suggestions.add(RichSuggestion(aci, () {
            FocusScope.of(context).requestFocus(FocusNode());
            decodeAndSelectPlace(aci.id!);
          }));
        }
      }

      displayAutoCompleteSuggestions(suggestions);
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getPlaceDataFromId(String baseurl, String placeId) async {
    final url = Uri.parse("${baseurl}/get/gmapaddress/" + "$placeId");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Error();
    }
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] == null) {
      throw Error();
    }
    final location = responseJson['result']['geometry']['location'];
    return location;
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  Future<void> decodeAndSelectPlace(String placeId) async {
    clearOverlay();

    try {
      final location = await getPlaceDataFromId(widget.apiBaseUrl, placeId);
      if (mapController.isCompleted) {
        moveToLocation(LatLng(location['lat'], location['lng']));
      }
    } catch (e) {
      print(e);
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox? appBarBox =
        this.appBarKey.currentContext?.findRenderObject() as RenderBox?;
    Size? size = appBarBox?.size;

    clearOverlay();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size?.width,
        left: appBarBox?.localToGlobal(Offset.zero).dx,
        top: appBarBox!.localToGlobal(Offset.zero).dy + 50,
        child: Material(
            elevation: 1,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: suggestions)),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry!);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String getLocationName() {
    if (this.locationResult == null) {
      return widget.localizationItem!.unnamedLocation;
    }

    for (NearbyPlace np in this.nearbyPlaces) {
      if (np.latLng == this.locationResult?.latLng &&
          np.name != this.locationResult?.locality) {
        this.locationResult?.name = np.name;
        return "${np.name}, ${this.locationResult?.locality}";
      }
    }

    return "${this.locationResult?.name}, ${this.locationResult?.locality}";
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(Marker(
          markerId: const MarkerId("selected-location"), position: latLng));
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  Future<void> getNearbyPlaces(LatLng latLng) async {
    try {
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
          "key=${widget.apiKey}&location=${latLng.latitude},${latLng.longitude}"
          "&radius=150&language=${widget.localizationItem!.languageCode}");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      this.nearbyPlaces.clear();

      for (Map<String, dynamic> item in responseJson['results']) {
        final nearbyPlace = NearbyPlace()
          ..name = item['name']
          ..icon = item['icon']
          ..latLng = LatLng(item['geometry']['location']['lat'],
              item['geometry']['location']['lng']);

        this.nearbyPlaces.add(nearbyPlace);
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        this.hasSearchTerm = false;
      });
    } catch (e) {
      //
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  Future<LocationResult?> reverseGeocodeLatLngRepo(
      LatLng latLng, String lang, String apiKey) async {
    final url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?"
        "latlng=${latLng.latitude},${latLng.longitude}&"
        "language=$lang&"
        "key=${apiKey}");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Error();
    }
    final responseJson = jsonDecode(response.body);
    if (responseJson['results'] == null) {
      throw Error();
    }
    var result = responseJson['results'][0];
    String name = "";
    String? locality,
        postalCode,
        country,
        administrativeAreaLevel1,
        administrativeAreaLevel2,
        city,
        subLocalityLevel1,
        subLocalityLevel2;
    if (result['address_components'] is List<dynamic> &&
        result['address_components'].length != null &&
        result['address_components'].length > 0) {
      for (var i = 0; i < result['address_components'].length; i++) {
        var tmp = result['address_components'][i];
        var types = tmp["types"] as List<dynamic>;
        var longName = tmp['long_name'];
        if (i == 0) {
          // [street_number]
          if (types.contains('street_number') ||
              types.contains('premise') ||
              types.contains('plus_code')) {
            name = longName;
          }
          // other index 0 types
          // [establishment, point_of_interest, subway_station, transit_station]
          // [premise]
          // [route]
        } else if (i == 1) {
          if (types.contains('route')) {
            name += ", $longName";
          }
        } else {
          if (types.contains("sublocality_level_1")) {
            subLocalityLevel1 = longName;
          } else if (types.contains("sublocality_level_2")) {
            subLocalityLevel2 = longName;
          } else if (types.contains("locality")) {
            locality = longName;
          } else if (types.contains("administrative_area_level_2")) {
            administrativeAreaLevel2 = longName;
          } else if (types.contains("administrative_area_level_1")) {
            administrativeAreaLevel1 = longName;
          } else if (types.contains("country")) {
            country = longName;
          } else if (types.contains('postal_code')) {
            postalCode = longName;
          }
        }
      }
    }
    locality = locality ?? administrativeAreaLevel1;
    city = locality;
    this.locationResult = LocationResult()
      ..name = name
      ..locality = locality
      ..latLng = latLng
      ..formattedAddress = result['formatted_address']
      ..placeId = result['place_id']
      ..postalCode = postalCode
      ..country = AddressComponent(name: country, shortName: country)
      ..administrativeAreaLevel1 = AddressComponent(
          name: administrativeAreaLevel1, shortName: administrativeAreaLevel1)
      ..administrativeAreaLevel2 = AddressComponent(
          name: administrativeAreaLevel2, shortName: administrativeAreaLevel2)
      ..city = AddressComponent(name: city, shortName: city)
      ..subLocalityLevel1 = AddressComponent(
          name: subLocalityLevel1, shortName: subLocalityLevel1)
      ..subLocalityLevel2 = AddressComponent(
          name: subLocalityLevel2, shortName: subLocalityLevel2);
    return locationResult;
  }

  Future<LocationResult?> reverseGeocodeLatLng(LatLng latLng) async {
    try {
      final result = await reverseGeocodeLatLngRepo(
          latLng, widget.localizationItem!.languageCode, widget.apiKey);
      setState(() {});
      return result;
    } catch (e) {
      print(e);
    }
    return null;
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15.0)),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    if (widget.showNearByPlaces) {
      getNearbyPlaces(latLng);
    }
  }

  Future<void> moveToCurrentUserLocation() async {
    if (widget.displayLocation != null) {
      moveToLocation(widget.displayLocation!);
      return;
    }
    if (_currentLocation != null) {
      moveToLocation(_currentLocation!);
    } else {
      moveToLocation(widget.defaultLocation);
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      bool? isOk = await _showLocationDisabledAlertDialog(context);
      if (isOk ?? false) {
        return Future.error(const LocationServiceDisabledException());
      } else {
        return Future.error('Location Services is not enabled');
      }
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      //return widget.defaultLocation;
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      final locationData = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 30));
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      //moveToLocation(target);
      print('target:$target');
      return target;
    } on TimeoutException catch (e) {
      d.log(e.toString());
      final locationData = await Geolocator.getLastKnownPosition();
      if (locationData != null) {
        return LatLng(locationData.latitude, locationData.longitude);
      } else {
        return widget.defaultLocation;
      }
    }
  }

  Future<dynamic> _showLocationDisabledAlertDialog(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isIOS) {
        return showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: const Text("Location is disabled"),
                content: const Text(
                    "To use location, go to your Settings App > Privacy > Location Services."),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  )
                ],
              );
            });
      }
    }
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("Location is disabled"),
            content: const Text(
                "The app needs to access your location. Please enable location service."),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text("OK"),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  // add delay to the map pop to avoid `Fatal Exception: java.lang.NullPointerException` error on Android
  Future<bool> _delayedPop() async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WillPopScope(
          onWillPop: () async => false,
          child: const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
        ),
        transitionDuration: Duration.zero,
        barrierDismissible: false,
        barrierColor: Colors.black45,
        opaque: false,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context)
      ..pop()
      ..pop(this.locationResult);
    return Future.value(false);
  }
}
