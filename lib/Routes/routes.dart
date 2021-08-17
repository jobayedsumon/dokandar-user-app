import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user/Auth/login_navigator.dart';
import 'package:user/HomeOrderAccount/Account/UI/ListItems/about_us_page.dart';
import 'package:user/HomeOrderAccount/Account/UI/ListItems/support_page.dart';
import 'package:user/HomeOrderAccount/Account/UI/ListItems/tnc_page.dart';
import 'package:user/HomeOrderAccount/Account/UI/account_page.dart';
import 'package:user/HomeOrderAccount/Home/UI/home.dart';
import 'package:user/HomeOrderAccount/Home/UI/order_placed_map.dart';
import 'package:user/HomeOrderAccount/Order/UI/order_page.dart';
import 'package:user/HomeOrderAccount/home_order_account.dart';
import 'package:user/Pages/view_cart.dart';
import 'package:user/pharmacy/pharmacart.dart';
import 'package:user/restaturantui/resturant_cart.dart';
import 'package:user/settingpack/settings.dart';
import 'package:user/walletrewardreffer/reffer/ui/reffernearn.dart';
import 'package:user/walletrewardreffer/reward/ui/reward.dart';
import 'package:user/walletrewardreffer/wallet/ui/wallet.dart';

class PageRoutes {
  static const String locationPage = 'location_page';
  static const String homeOrderAccountPage = 'home_order_account';
  static const String homePage = 'home_page';
  static const String accountPage = 'account_page';
  static const String orderPage = 'order_page';
  static const String tncPage = 'tnc_page';
  static const String aboutUsPage = 'about_us_page';
  static const String settings = 'settings';
  static const String savedAddressesPage = 'saved_addresses_page';
  static const String supportPage = 'support_page';
  static const String loginNavigator = 'login_navigator';
  static const String orderMapPage = 'order_map_page';
  static const String viewCart = 'view_cart';
  static const String restviewCart = 'restviewCart';
  static const String orderPlaced = 'order_placed';
  static const String paymentMethod = 'payment_method';
  static const String wallet = 'wallet';
  static const String reward = 'reward';
  static const String reffernearn = 'reffernearn';
  static const String returanthome = 'returanthome';
  static const String pharmacart = 'pharmacart';

  Map<String, WidgetBuilder> routes() {
    return {
      homeOrderAccountPage: (context) => HomeOrderAccount(),
      homePage: (context) => HomePage(),
      orderPage: (context) => OrderPage(),
      accountPage: (context) => AccountPage(),
      tncPage: (context) => TncPage(),
      aboutUsPage: (context) => AboutUsPage(),
      supportPage: (context) => SupportPage(),
      loginNavigator: (context) => LoginNavigator(),
      orderMapPage: (context) => OrderMapPage(),
      viewCart: (context) => ViewCart(),
      wallet: (context) => Wallet(),
      reward: (context) => Reward(),
      reffernearn: (context) => RefferScreen(),
      settings: (context) => Settings(),
      restviewCart: (context) => RestuarantViewCart(),
      pharmacart: (context) => PharmaViewCart(),
    };
  }
}
