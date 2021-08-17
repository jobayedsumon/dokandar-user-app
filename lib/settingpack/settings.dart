import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';
import 'package:user/baseurlp/baseurl.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingState();
  }
}

class SettingState extends State<Settings> {
  bool _switchValueEmail = true;
  bool _switchValueSms = true;
  bool _switchValueInApp = true;
  dynamic userId;

  @override
  void initState() {
    getSharePrefOrUserId();
    super.initState();
  }

  getSharePrefOrUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (preferences.containsKey('emailnoti')) {
        _switchValueEmail = preferences.getBool('emailnoti');
      } else {
        _switchValueEmail = true;
      }
      if (preferences.containsKey('smsnoti')) {
        _switchValueSms = preferences.getBool('smsnoti');
      } else {
        _switchValueSms = true;
      }
      if (preferences.containsKey('inappnoti')) {
        _switchValueInApp = preferences.getBool('inappnoti');
      } else {
        _switchValueInApp = true;
      }

      userId = preferences.getInt('user_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
        message: 'Saving setting please wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CupertinoActivityIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kWhiteColor,
        elevation: 0.0,
        title: Text(
          'Settings',
          style: headingStyle,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
            child: RaisedButton(
              onPressed: () {
                pr.show();
                hitService(context, pr);
              },
              child: Text(
                'Save',
                style:
                    TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
              ),
              color: kMainColor,
              highlightColor: kMainColor,
              focusColor: kMainColor,
              splashColor: kMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Notification',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: kHintColor),
              ),
            ),
            Container(
                color: kWhiteColor,
                margin: EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SMS',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: kHintColor),
                          ),
                          CupertinoSwitch(
                            value: _switchValueSms,
                            activeColor: kMainColor,
                            onChanged: (value) {
                              setState(() {
                                _switchValueSms = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'E-MAIL',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: kHintColor),
                          ),
                          CupertinoSwitch(
                            value: _switchValueEmail,
                            activeColor: kMainColor,
                            onChanged: (value) {
                              setState(() {
                                _switchValueEmail = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'In-App',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: kHintColor),
                          ),
                          CupertinoSwitch(
                            value: _switchValueInApp,
                            activeColor: kMainColor,
                            onChanged: (value) {
                              setState(() {
                                _switchValueInApp = value;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void hitService(BuildContext context, ProgressDialog pr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = notificationby;
    await http.post(url, body: {
      'user_id': '${userId}',
      'sms': '${(_switchValueSms) ? 1 : 0}',
      'app': '${(_switchValueInApp) ? 1 : 0}',
      'email': '${(_switchValueEmail) ? 1 : 0}'
    }).then((response) {
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          prefs.setBool('emailnoti', _switchValueEmail);
          prefs.setBool('smsnoti', _switchValueSms);
          prefs.setBool('inappnoti', _switchValueInApp);
          pr.hide();
          Toast.show('Settings Updated', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        } else {
          Toast.show('Settings Updated', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          pr.hide();
        }
      } else {
        pr.hide();
      }
    }).catchError((e) {
      print(e);
      pr.hide();
    });
  }
}
