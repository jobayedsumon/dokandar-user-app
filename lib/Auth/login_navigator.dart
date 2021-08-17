import 'package:flutter/material.dart';
import 'package:user/Auth/MobileNumber/UI/phone_number.dart';
import 'package:user/Auth/Registration/UI/register_page.dart';
import 'package:user/Auth/Verification/UI/verification_page.dart';
import 'package:user/HomeOrderAccount/home_order_account.dart';
import 'package:user/Routes/routes.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginRoutes {
  static const String loginRoot = 'login/';
  static const String registration = 'login/registration';
  static const String verification = 'login/verification';
  static const String homepage = 'login/home_order_account';
}

class LoginNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = navigatorKey.currentState.canPop();
        if (canPop) {
          navigatorKey.currentState.pop();
        }
        return !canPop;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: LoginRoutes.loginRoot,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case LoginRoutes.loginRoot:
              builder = (BuildContext _) => PhoneNumber_New();
              break;
            case LoginRoutes.registration:
              builder = (BuildContext _) => RegisterPage();
              break;
            case LoginRoutes.verification:
              builder = (BuildContext _) => VerificationPage(
                    () {
                      Navigator.popAndPushNamed(
                          context, PageRoutes.homeOrderAccountPage);
                    },
                  );
              break;
            case LoginRoutes.homepage:
              builder = (BuildContext _) => HomeOrderAccount();
              break;
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
        onPopPage: (Route<dynamic> route, dynamic result) {
          return route.didPop(result);
        },
      ),
    );
  }
}
