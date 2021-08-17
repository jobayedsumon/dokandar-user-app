import 'dart:convert';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:user/HomeOrderAccount/Home/UI/home.dart';
import 'package:user/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:user/HomeOrderAccount/offer/ui/offerui.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';

class HomeStateless extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeOrderAccount(),
    );
  }
}

class HomeOrderAccount extends StatefulWidget {
  @override
  _HomeOrderAccountState createState() => _HomeOrderAccountState();
}

class _HomeOrderAccountState extends State<HomeOrderAccount> {
  int _currentIndex = 0;
  double bottomNavBarHeight = 60.0;
  CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    _navigationController =
        new CircularBottomNavigationController(_currentIndex);
    getCurrency();
    super.initState();
  }

  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;
    var client = http.Client();
    client.get(currencyUrl).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {
      print(e);
    });
  }

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.home, "Home", Colors.blue,
        labelStyle: TextStyle(fontWeight: FontWeight.normal)),
    new TabItem(Icons.circle_notifications, "Update", Colors.orange,
        labelStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    new TabItem(Icons.list_rounded, "Order", Colors.red),
    new TabItem(Icons.account_circle, "Account", Colors.cyan),
  ]);

  final List<Widget> _children = [
    HomePage(),
    OfferScreen(),
    OrderPage(),
    AccountPage(),
  ];

  void onTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: bottomNav(context),
    );
  }

  Widget bottomNav(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: kWhiteColor,
      child: CircularBottomNavigation(
        tabItems,
        normalIconColor: Colors.pinkAccent,
        controller: _navigationController,
        barHeight: 45,
        circleSize: 45,
        barBackgroundColor: kWhiteColor,
        iconsSize: 30,
        circleStrokeWidth: 5,
        animationDuration: Duration(milliseconds: 500),
        selectedCallback: (int selectedPos) {
          setState(() {
            this._currentIndex = selectedPos;
          });
        },
      ),
    );
  }
}
