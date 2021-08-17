import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';

class RefferScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RefferScreenState();
  }
}

class RefferScreenState extends State<RefferScreen> {
  var refferText = '';
  var appLink = '';

  var refferCode = '';
  bool isFetchStore = false;

  dynamic elestxt = 'Fetching data..';

  @override
  void initState() {
    super.initState();
    getRefferText();
  }

  void getRefferText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      elestxt = 'Fetching reward points';
      isFetchStore = true;
      refferCode = prefs.getString('refferal_code');
    });
    var client = http.Client();
    var url = reffermessage;
    client.get(url).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          refferText = '${dataList[0]['reffer_message']}';
          appLink = dataList[0]['app_link'];
        });
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  void getRefferCode() async {
    setState(() {
      elestxt = 'Fetching share code..';
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id');
    var url = promocode_regenerate;
    var client = http.Client();
    client.post(url, body: {
      'user_id': '${userId}',
    }).then((value) {
      if (value.statusCode == 200) {
        var redemData = jsonDecode(value.body);
        print('${value.body}');
        if (redemData['status'] == 1) {
          prefs.setString('refferal_code', '${redemData['PromoCode']}');
          print('${value.body}');
          setState(() {
            refferCode = redemData['PromoCode'];
          });
          Toast.show(redemData['message'], context,
              duration: Toast.LENGTH_SHORT);
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: kWhiteColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Invite n Earn',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: kMainTextColor),
              ),
            ],
          ),
        ),
      ),
      body: (!isFetchStore)
          ? Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Positioned(
                    top: 40,
                    child: Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'images/refernearn/refernearn.jpg'),
                              fit: BoxFit.fill)),
                    )),
                Positioned(
                  top: 210,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      '${refferText}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 25,
                          color: kMainTextColor),
                    ),
                  ),
                ),
                Positioned(
                  top: 270,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Share your the code below or ask them to enter it during they signup. Earn when your friends signup on our app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: kHintColor),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 90,
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: refferCode));
                        Toast.show('Code Coppied', context,
                            duration: Toast.LENGTH_SHORT);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Card(
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${refferCode}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kMainTextColor),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Tap to copy',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: kHintColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                Positioned(
                    bottom: 15,
                    left: 0.0,
                    right: 0.0,
                    child: GestureDetector(
                      onTap: () {
                        if (refferCode != null && refferCode.length > 0) {
                          share();
                        } else {
                          Toast.show(
                              'Generate your shared code first.', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
                          getRefferCode();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 52,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: kMainColor),
                        child: Text(
                          'Invite Friends',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: kWhiteColor),
                        ),
                      ),
                    ))
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '${elestxt}',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kMainTextColor),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: appname,
        text: '${refferText}\nEnter this referral code ${refferCode}.',
        linkUrl: '${appLink}',
        chooserTitle: 'Share ${appname}');
  }
}
