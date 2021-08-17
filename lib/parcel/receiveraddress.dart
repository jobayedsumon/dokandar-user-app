import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/constantfile.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/parcel/parcel_details.dart';
import 'package:user/parcel/pharmacybean/chargelistuser.dart';
import 'package:user/parcel/pharmacybean/parceladdress.dart';

class AddressTo extends StatefulWidget {
  final dynamic vendor_name;
  final dynamic vendor_id;
  final dynamic distance;
  final ParcelAddress senderAddress;

  AddressTo(
      this.vendor_name, this.vendor_id, this.distance, this.senderAddress);

  @override
  State<StatefulWidget> createState() {
    return AddressToState();
  }
}

class AddressToState extends State<AddressTo> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);
  TextEditingController houseno = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController sendername = TextEditingController();
  TextEditingController sendercontact = TextEditingController();

  String currentAddress = '';
  dynamic lat = 0.0;
  dynamic lng = 0.0;

  bool isFetch = false;

  dynamic distance = 0.0;
  dynamic charges = 0.0;
  dynamic city_id;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  void _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        double lng = position.longitude;
        final coordinates = new Coordinates(lat, lng);
        await Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .then((value) {
          for (int i = 0; i < value.length; i++) {
            print('${value[i].locality}');
            if (value[i].locality != null && value[i].locality.length > 1) {
              setState(() {
                city.text = value[i].locality;
                pincode.text = value[i].postalCode;
                state.text = value[i].adminArea;
              });
              break;
            }
          }
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'Address detail\'s',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, top: 20, bottom: 10.0),
              child: Text(
                'Receiver Address',
                style: TextStyle(
                    fontSize: 18,
                    color: black_color,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Receiver Name',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendername,
                        decoration: InputDecoration(
                          hintText: 'Receiver Name',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Receiver Contact No.',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendercontact,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Receiver Contact No.',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Address',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getPlaces(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Card(
                      elevation: 2,
                      color: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          maxLines: 5,
                          readOnly: true,
                          controller: address,
                          enabled: (address.text.length == 0) ? false : true,
                          decoration: InputDecoration(
                            hintText: 'Enter your address',
                            hintStyle: TextStyle(fontSize: 15),
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.length == 1) {
                              getPlaces(context);
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'House No/Flat No',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: houseno,
                        decoration: InputDecoration(
                          hintText: 'House No/Flat No',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Pin Code',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: pincode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Pin Code',
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'City',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: city,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'City',
                                    enabled: false,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Landmark',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: landmark,
                        decoration: InputDecoration(
                          hintText: 'Landmark',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'State',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: state,
                        decoration: InputDecoration(
                          hintText: 'State',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  showProgressDialog(
                      'please wait while we setting your cart', pr);
                  hitServiceCount(pr, context);
                },
                child: Card(
                  elevation: 2,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: kWhiteColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaces(context) async {
    PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      mode: Mode.fullscreen,
      sessionToken: Uuid().generateV4(),
      onError: (response) {
        print('${response.errorMessage}');
      },
      language: "en",
    ).then((value) {
      displayPrediction(value);
    }).catchError((e) {
      print(e);
    });
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      _getCameraMoveLocation(
          LatLng(lat, lng), '${detail.result.formattedAddress}');
    }
  }

  void _getCameraMoveLocation(LatLng data, addressd) async {
    setState(() {
      currentAddress = '${addressd}';
      lat = data.latitude;
      lng = data.longitude;
    });
    final coordinates = new Coordinates(lat, lng);
    await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .then((value) {
      for (int i = 0; i < value.length; i++) {
        print('${value[i].locality}');
        if (value[i].locality != null && value[i].locality.length > 1) {
          setState(() {
            city.text = value[i].locality;
            pincode.text = value[i].postalCode;
            state.text = value[i].adminArea;
            currentAddress =
                currentAddress.replaceAll('${value[i].locality},', '');
            currentAddress = currentAddress.replaceAll('${pincode.text},', '');
            currentAddress = currentAddress.replaceAll('${state.text},', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].locality}', '');
            currentAddress = currentAddress.replaceAll('${pincode.text}', '');
            currentAddress = currentAddress.replaceAll('${state.text}', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].countryName}', '');
            address.text = currentAddress;
          });
          break;
        }
      }
    });
  }

  showProgressDialog(String text, ProgressDialog pr) {
    pr.style(
        message: '${text}',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  }

  void hitServiceCount(ProgressDialog pr, BuildContext context) async {
    print('${widget.vendor_id}');
    pr.show();
    var chargeList = parcel_listcharges;
    var client = http.Client();
    client.post(chargeList, body: {'vendor_id': '${widget.vendor_id}'}).then(
        (value) {
      if (value.statusCode == 200) {
        print('${value.body}');
        pr.hide();
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsLst = jsonData['data'] as List;
          List<ChargeListBean> cityFetcjList =
              jsLst.map((e) => ChargeListBean.fromJson(e)).toList();
          if (cityFetcjList.length > 0) {
            for (int i = 0; i < cityFetcjList.length; i++) {
              if (cityFetcjList[i].city_name.toString().contains(city.text)) {
                double disForCharge = calculateDistance(
                    widget.senderAddress.lat,
                    widget.senderAddress.lng,
                    lat,
                    lng);
                setState(() {
                  city_id = '${cityFetcjList[i].city_id}';
                  charges = '${cityFetcjList[i].parcel_charge}';
                });
                if (houseno.text != null &&
                    pincode.text != null &&
                    city.text != null &&
                    landmark.text != null &&
                    address.text != null &&
                    state.text != null &&
                    lat != null &&
                    lng != null &&
                    sendercontact.text != null &&
                    sendername.text != null) {
                  ParcelAddress parcelAddress = ParcelAddress(
                      houseno.text,
                      pincode.text,
                      city.text,
                      landmark.text,
                      address.text,
                      state.text,
                      lat,
                      lng,
                      sendername.text,
                      sendercontact.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParcelDetails(
                              widget.vendor_id,
                              widget.vendor_name,
                              widget.distance,
                              widget.senderAddress,
                              parcelAddress,
                              city_id,
                              charges,
                              disForCharge)));
                } else {
                  Toast.show('please enter all details to continue!', context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                }
                break;
              }
            }
          } else {
            Toast.show('we not provide service in this area!', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
        } else {
          Toast.show('we not provide service in this area!', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        }
      }
    }).catchError((e) {
      pr.hide();
      print(e);
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
