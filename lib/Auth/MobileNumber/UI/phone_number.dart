import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Auth/login_navigator.dart';
import 'package:user/Locale/locales.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';

class PhoneNumber_New extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhoneNumber(),
    );
  }
}

class PhoneNumber extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PhoneNumberState();
  }
}

class PhoneNumberState extends State<PhoneNumber> {
  static const String id = 'phone_number';
  final TextEditingController _controller = TextEditingController();
  String isoCode = '+880';
  int numberLimit = 10;
  var showDialogBox = false;

  @override
  void initState() {
    super.initState();
    getCountryCode();
  }

  void getCountryCode() async {
    setState(() {
      showDialogBox = true;
    });
    var url = country_code;
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['Data'] as List;
          if (tagObjsJson.isNotEmpty) {
            setState(() {
              showDialogBox = false;
              numberLimit = int.parse('${tagObjsJson[0]['number_limit']}');
              isoCode = tagObjsJson[0]['country_code'];
            });
          } else {
            setState(() {
              showDialogBox = false;
            });
          }
        } else {
          setState(() {
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return _handlePopBack();
        },
        child: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            "images/logos/logo_user.png", //gomarketdelivery logo
                            height: 130.0,
                            width: 99.7,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 5),
                            child: Text(
                              '${appname}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          //text on page
                          Text(AppLocalizations.of(context).bodyText1,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1),
                          Text(
                            AppLocalizations.of(context).bodyText2,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 10.0),
                          Visibility(
                              visible: showDialogBox,
                              child: Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 52.0,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "images/logos/Delivery.gif",
                      width: MediaQuery.of(context).size.width, //footer image
                    ),
                  ),
                  PositionedDirectional(
                      bottom: 0.0,
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CountryCodePicker(
                              onChanged: (value) {
                                isoCode = value.toString();
                              },
                              builder: (value) => buildButton(value),
                              initialSelection: '+880',
                              textStyle: Theme.of(context).textTheme.caption,
                              showFlag: false,
                              showFlagDialog: true,
                              favorite: ['+880', 'BD'],
                            ),
                            //Text('${isoCode}'),
                            SizedBox(
                              width: 5.0,
                            ),
                            //takes phone number as input
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                child: TextFormField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  readOnly: false,
                                  textAlign: TextAlign.left,
                                  enabled: !showDialogBox,
                                  decoration: InputDecoration(
                                    hintText:
                                        AppLocalizations.of(context).mobileText,
                                    border: InputBorder.none,
                                    counter: Offstage(),
                                    contentPadding: EdgeInsets.only(left: 30),
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: kHintColor,
                                        fontSize: 16),
                                  ),
                                  maxLength: numberLimit,
                                ),
                              ),
                            ),
                            RaisedButton(
                              child: Text(
                                AppLocalizations.of(context).continueText,
                                style: TextStyle(
                                    color: kWhiteColor,
                                    fontWeight: FontWeight.w400),
                              ),
                              color: kMainColor,
                              highlightColor: kMainColor,
                              focusColor: kMainColor,
                              splashColor: kMainColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: () {
                                if (!showDialogBox) {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  setState(() {
                                    showDialogBox = true;
                                  });
                                  if (_controller.text.length < 10) {
                                    setState(() {
                                      showDialogBox = false;
                                    });
                                    Toast.show(
                                        "Enter valid mobile number!", context,
                                        gravity: Toast.BOTTOM);
                                  } else {
                                    hitService(
                                        isoCode, _controller.text, context);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      )),
                ],
              )),
        ),
      ),
    );
  }

  void hitService(
      String isoCode, String phoneNumber, BuildContext context) async {
    var url = userRegistration;
    var client = http.Client();
    client.post(url, body: {'user_phone': '${isoCode}${phoneNumber}'}).then(
        (response) async {
      print('Response Body 1: - ${response.body} - ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        Toast.show(jsonData['message'], context, gravity: Toast.BOTTOM);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("user_phone", '${isoCode}${phoneNumber}');
        prefs.setInt("number_limit", numberLimit);
        if (jsonData['status'] == 1) {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.verification);
        } else {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.registration);
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  buildButton(CountryCode isoCode) {
    return Row(
      children: <Widget>[
        Text(
          '$isoCode',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Future<bool> _handlePopBack() async {
    bool isVal = false;
    if (showDialogBox) {
      setState(() {
        showDialogBox = false;
      });
    } else {
      isVal = true;
    }
    return isVal;
  }
}
