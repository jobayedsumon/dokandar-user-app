import 'dart:async';
import 'dart:convert';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/bean/currencybean.dart';

class VerificationPage extends StatelessWidget {
  final VoidCallback onVerificationDone;

  VerificationPage(this.onVerificationDone);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          'Verification',
          style: headingStyle,
        ),
      ),
      body: OtpVerify(onVerificationDone),
    );
  }
}

//otp verification class
class OtpVerify extends StatefulWidget {
  final VoidCallback onVerificationDone;

  OtpVerify(this.onVerificationDone);

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";

  bool showTimer = true;

  @override
  void initState() {
    messaging = FirebaseMessaging();
    messaging.getToken().then((value) {
      token = value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    MobileNumberArg mobileNumberArg = ModalRoute.of(context).settings.arguments;

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 100,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: 10, bottom: 5, right: 80, left: 80),
                      child: Center(
                        child: Text(
                          'Verify your phone number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kMainTextColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Text(
                        "Enter your otp code here.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10.0),
                          PinCodeTextField(
                            autofocus: true,
                            controller: _controller,
                            hideCharacter: false,
                            highlight: true,
                            highlightColor: kHintColor,
                            defaultBorderColor: kMainColor,
                            hasTextBorderColor: kMainColor,
                            maxLength: 4,
                            pinBoxRadius: 40,
                            onDone: (text) {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              verificaitonPin = text;
                            },
                            pinBoxWidth: 60,
                            pinBoxHeight: 60,
                            hasUnderline: false,
                            wrapAlignment: WrapAlignment.spaceAround,
                            pinBoxDecoration: ProvidedPinBoxDecoration
                                .roundedPinBoxDecoration,
                            pinTextStyle: TextStyle(fontSize: 22.0),
                            pinTextAnimatedSwitcherTransition:
                                ProvidedPinBoxTextAnimation.scalingTransition,
                            pinTextAnimatedSwitcherDuration:
                                Duration(milliseconds: 300),
                            highlightAnimationBeginColor: Colors.black,
                            highlightAnimationEndColor: Colors.white12,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 15.0),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Didn't you receive any code? Wait!",
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          showTimer
                              ? CircularCountDownTimer(
                                  duration: 40,
                                  initialDuration: 0,
                                  controller: CountDownController(),
                                  width: 80.0,
                                  height: 80.0,
                                  ringColor: Colors.grey[300],
                                  ringGradient: null,
                                  fillColor: Colors.pink[300],
                                  fillGradient: null,
                                  backgroundColor: Colors.pink[400],
                                  backgroundGradient: null,
                                  strokeWidth: 20.0,
                                  strokeCap: StrokeCap.round,
                                  textStyle: TextStyle(
                                      fontSize: 33.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textFormat: CountdownTextFormat.S,
                                  isReverse: true,
                                  isReverseAnimation: true,
                                  isTimerTextShown: true,
                                  autoStart: true,
                                  onStart: () {
                                    print('Countdown Started');
                                  },
                                  onComplete: () {
                                    print('Countdown Ended');
                                    setState(() {
                                      showTimer = false;
                                    });
                                  },
                                )
                              : FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "TRY AGAIN",
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: kMainColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
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
                    SizedBox(
                      height: 40,
                    ),
                  ],
                )),
            Positioned(
              bottom: 12,
              left: 20,
              right: 20.0,
              child: InkWell(
                onTap: () {
                  if (!showDialogBox) {
                    setState(() {
                      showDialogBox = true;
                    });
                    hitService(verificaitonPin, context);
                  }
//                  widget.onVerificationDone();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 52,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: kMainColor),
                  child: Text(
                    'Verify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void hitService(String verificaitonPin, BuildContext context) async {
    if (token != null && token.toString().length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = verifyPhone;
      await http.post(url, body: {
        'phone': prefs.getString('user_phone'),
        'otp': verificaitonPin,
        'device_id': '${token}'
      }).then((response) {
        print('Response Body: - ${response.body}');
        if (response.statusCode == 200) {
          print('Response Body: - ${response.body}');
          var jsonData = jsonDecode(response.body);
          if (jsonData['status'] == 1) {
            var userId = int.parse('${jsonData['data']['user_id']}');
            prefs.setInt("user_id", userId);
            prefs.setString("user_name", jsonData['data']['user_name']);
            prefs.setString("user_email", jsonData['data']['user_email']);
            prefs.setString("user_image", jsonData['data']['user_image']);
            prefs.setString("user_phone", jsonData['data']['user_phone']);
            prefs.setString("user_password", jsonData['data']['user_password']);
            prefs.setString(
                "wallet_credits", jsonData['data']['wallet_credits']);
            prefs.setString("first_recharge_coupon",
                jsonData['data']['first_recharge_coupon']);
            prefs.setBool("phoneverifed", true);
            prefs.setBool("islogin", true);
            prefs.setString("refferal_code", jsonData['data']['referral_code']);
            if (jsonData['currency'] != null) {
              CurrencyData currencyData =
                  CurrencyData.fromJson(jsonData['currency']);
              print('${currencyData.toString()}');
              prefs.setString("curency", '${currencyData.currency_sign}');
            }
            widget.onVerificationDone();
          } else {
            prefs.setBool("phoneverifed", false);
            prefs.setBool("islogin", false);
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
    } else {
      messaging.getToken().then((value) {
        token = value;
        hitService(verificaitonPin, context);
      });
    }
  }
}
