import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aamarpay/aamarpay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Components/list_tile.dart';
import 'package:user/Pages/order_placed.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/bean/cartdetails.dart';
import 'package:user/bean/couponlist.dart';
import 'package:user/bean/paymentstatus.dart';

class PaymentPharmaPage extends StatefulWidget {
  final dynamic vendor_ids;
  final dynamic order_id;
  final dynamic cart_id;
  final double totalAmount;
  final List<PaymentVia> tagObjs;

  PaymentPharmaPage(this.vendor_ids, this.order_id, this.cart_id,
      this.totalAmount, this.tagObjs);

  @override
  State<StatefulWidget> createState() {
    return PaymentPharmaPageState(order_id, cart_id, totalAmount, tagObjs);
  }
}

class PaymentPharmaPageState extends State<PaymentPharmaPage> {
  Razorpay _razorpay;
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  List<PaymentVia> paymentVia;
  dynamic currency = '';

  bool visiblity = false;
  String promocode = '';
  final dynamic order_id;
  final dynamic cart_id;

  bool razor = false;
  bool paystack = false;

  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  String _cardNumber;
  String _cvv;
  int _expiryMonth = 0;
  int _expiryYear = 0;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  var _inProgress = false;

  var walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;

  bool isLoading = false;

  PaymentPharmaPageState(
      this.order_id, this.cart_id, this.totalAmount, this.paymentVia);

  List<CouponList> couponL = [];

  @override
  void initState() {
    newtotalAmount = double.parse('${totalAmount}');
    super.initState();
    getCouponList();
    getWalletAmount();
  }

  void getWalletAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    setState(() {
      isFetch = true;
      currency = prefs.getString('curency');
    });
    var client = http.Client();
    var url = showWalletAmount;
    client.post(url, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          walletAmount = double.parse('${dataList[0]['wallet_credits']}');
          if (totalAmount > walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = totalAmount - walletAmount;
          } else if (totalAmount < walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = 0.0;
          } else {
            iswallet = false;
          }
        });
      }
      setState(() {
        isFetch = false;
      });
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }

  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${prefs.getString('user_name')}',
        'description': 'Grocery Shopping',
        'prefill': {
          'contact': '${prefs.getString('user_phone')}',
          'email': '${prefs.getString('user_email')}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e);
      }
    });
  }

  void payStatck(String key) async {
    PaystackPlugin.initialize(publicKey: key);
  }

  void getCouponList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String vendorId = preferences.getString('ph_vendor_id');
    setState(() {
      currency = preferences.getString('curency');
    });
    var url = couponList;
    http.post(url, body: {
      'cart_id': '$cart_id',
      'vendor_id': '${vendorId}'
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CouponList> tagObjs = tagObjsJson
              .map((tagJson) => CouponList.fromJson(tagJson))
              .toList();
          setState(() {
            couponL.clear();
            couponL = tagObjs;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Select Payment Method',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: kMainTextColor),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                'Amount to Pay $currency $totalAmount',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: kDisabledColor),
              ),
            ],
          ),
        ),
      ),
      body: isFetch
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 64,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 64,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    primary: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Visibility(
                          visible: (iswallet || isCoupon) ? true : false,
                          //(iswallet||isCoupon)?true:false
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                color: kCardBackgroundColor,
                                child: Text(
                                  'WALLET',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: kDisabledColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.67),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: iswallet, //iswallet
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'images/payment/wallet.png',
                                                height: 20.3,
                                              ),
                                              SizedBox(
                                                width: 25,
                                              ),
                                              Text(
                                                'Wallet Amount',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${currency} ${walletAmount}',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(
                                      visible: iswallet, //iswallet
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'images/payment/wallet.png',
                                                height: 20.3,
                                              ),
                                              SizedBox(
                                                width: 25,
                                              ),
                                              Text(
                                                'Wallet Used Amount',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '- ${currency} ${walletUsedAmount}',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(
                                      visible: isCoupon, //isCoupon
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'images/payment/coupon_amount.png',
                                                height: 20.3,
                                              ),
                                              SizedBox(
                                                width: 25,
                                              ),
                                              Text(
                                                'Coupon Amount',
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '- ${currency} ${coupAmount}',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'images/payment/amount.png',
                                              height: 20.3,
                                            ),
                                            SizedBox(
                                              width: 25,
                                            ),
                                            Text(
                                              'Order Amount',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${currency} ${newtotalAmount}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: (totalAmount > 0.0) ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                color: kCardBackgroundColor,
                                child: Text(
                                  'CASH',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: kDisabledColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.67),
                                ),
                              ),
                              BuildListTile(
                                  image: 'images/payment/amount.png',
                                  text: 'Cash on Delivery',
                                  onTap: () {
                                    setState(() {
                                      setProgressText =
                                          'Proceeding to placed order please wait!....';
                                      showDialogBox = true;
                                    });
                                    placedOrder("success", "COD");
                                  }
//                    Navigator.popAndPushNamed(context, PageRoutes.orderPlaced),
                                  ),
                              (totalAmount > 0.0 &&
                                      paymentVia != null &&
                                      paymentVia.length > 0)
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      color: kCardBackgroundColor,
                                      child: Text(
                                        'ONLINE PAYMENT',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                                color: kDisabledColor,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.67),
                                      ),
                                    )
                                  : Container(),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: FutureBuilder(
                                    future: buildAamarpayData(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        return AamarpayData(
                                            returnUrl: (url) {
                                              print(url);
                                            },
                                            isLoading: (v) {
                                              setState(() {
                                                isLoading = v;
                                              });
                                            },
                                            paymentStatus: (status) {
                                              print(status);
                                              if (status == 'success') {
                                                setState(() {
                                                  setProgressText =
                                                      'Proceeding to placed order please wait!....';
                                                  showDialogBox = true;
                                                });
                                                placedOrder(
                                                    "success", "ONLINE");
                                              }
                                            },
                                            cancelUrl:
                                                "example.com/payment/cancel",
                                            successUrl:
                                                "example.com/payment/confirm",
                                            failUrl: "example.com/payment/fail",
                                            customerEmail: snapshot.data
                                                .getString('user_email'),
                                            customerMobile: snapshot.data
                                                .getString('user_phone'),
                                            customerName: snapshot.data
                                                .getString('user_name'),
                                            signature:
                                                "b1094e13af7b1ad5bbb55592e53ec7c7",
                                            storeID: "dokandar",
                                            transactionAmount: totalAmount,
                                            transactionID: cart_id.toString(),
                                            description:
                                                "ORDER ID: ${cart_id.toString()}",
                                            url: "https://secure.aamarpay.com",
                                            child: isLoading
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Container(
                                                    padding: EdgeInsets.all(20),
                                                    height: 60,
                                                    child: Row(
                                                      children: [
                                                        Image(
                                                            image: AssetImage(
                                                                'images/payment/credit_card.png')),
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                        Text(
                                                          "ONLINE PAYMENT",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ],
                                                    ),
                                                  ));
                                      } else {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                    },
                                  )),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                color: kCardBackgroundColor,
                                child: Text(
                                  'Promo Code',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: kDisabledColor,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.67),
                                ),
                              ),
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 6.7,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            height: 45,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Enter Your promo code",
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: kMainColor,
                                                      width: 1),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: kMainColor,
                                                      width: 1),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: kMainColor,
                                                      width: 1),
                                                ),
                                              ),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13),
                                              cursorColor: kMainColor,
                                              showCursor: false,
                                              keyboardType: TextInputType.text,
                                              onChanged: (val) {
                                                setState(() => promocode = val);
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (totalAmount != 0.0) {
                                                  visiblity = !visiblity;
                                                  setProgressText =
                                                      'Applying coupon please wait!....';
                                                  showDialogBox = true;
                                                  appCoupon(promocode);
                                                } else {
                                                  Toast.show(
                                                      'coupon code not applicable!',
                                                      context,
                                                      duration:
                                                          Toast.LENGTH_SHORT,
                                                      gravity: Toast.CENTER);
                                                }
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.28,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  color: kMainColor),
                                              child: Text(
                                                'Apply',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 15,
                                                    color: kWhiteColor),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: kCardBackgroundColor,
                                thickness: 6.7,
                              ),
                              // Container(
                              //   margin: EdgeInsets.symmetric(horizontal: 20),
                              //   alignment: Alignment.topCenter,
                              //   child: Column(
                              //     children: <Widget>[
                              //       // Container(
                              //       //   height: 52,
                              //       //   child: Row(
                              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //       //     children: <Widget>[
                              //       //       Text(
                              //       //         'Promo Code',
                              //       //         textAlign: TextAlign.start,
                              //       //         style: TextStyle(
                              //       //             fontWeight: FontWeight.w600,
                              //       //             fontSize: 18,
                              //       //             color: kMainTextColor),
                              //       //       ),
                              //       //       InkWell(
                              //       //         onTap: () {
                              //       //           setState(() {
                              //       //             visiblity = !visiblity;
                              //       //           });
                              //       //         },
                              //       //         child: Icon(visiblity
                              //       //             ? Icons.keyboard_arrow_down
                              //       //             : Icons.keyboard_arrow_right),
                              //       //       )
                              //       //     ],
                              //       //   ),
                              //       // ),
                              //       // Visibility(
                              //       //   visible: visiblity,
                              //       //   child: Column(
                              //       //     children: <Widget>[
                              //       //       Divider(
                              //       //         color: kCardBackgroundColor,
                              //       //         thickness: 6.7,
                              //       //       ),
                              //       //       Container(
                              //       //         width: MediaQuery
                              //       //             .of(context)
                              //       //             .size
                              //       //             .width,
                              //       //         child: Row(
                              //       //           mainAxisAlignment:
                              //       //           MainAxisAlignment.spaceBetween,
                              //       //           children: <Widget>[
                              //       //             Container(
                              //       //               width:
                              //       //               MediaQuery
                              //       //                   .of(context)
                              //       //                   .size
                              //       //                   .width *
                              //       //                   0.55,
                              //       //               height: 45,
                              //       //               alignment: Alignment.centerLeft,
                              //       //               margin: EdgeInsets.only(
                              //       //                   left: 5,
                              //       //                   right: 5,
                              //       //                   top: 5,
                              //       //                   bottom: 5),
                              //       //               padding:
                              //       //               EdgeInsets.symmetric(vertical: 2.0),
                              //       //               child: TextFormField(
                              //       //                 textAlign: TextAlign.center,
                              //       //                 decoration: InputDecoration(
                              //       //                   hintText: "Enter Your promo code",
                              //       //                   fillColor: Colors.white,
                              //       //                   border: OutlineInputBorder(
                              //       //                     borderRadius:
                              //       //                     BorderRadius.circular(10.0),
                              //       //                     borderSide: BorderSide(
                              //       //                         color: kMainColor, width: 1),
                              //       //                   ),
                              //       //                   focusedBorder: OutlineInputBorder(
                              //       //                     borderRadius:
                              //       //                     BorderRadius.circular(10.0),
                              //       //                     borderSide: BorderSide(
                              //       //                         color: kMainColor, width: 1),
                              //       //                   ),
                              //       //                   enabledBorder: OutlineInputBorder(
                              //       //                     borderRadius:
                              //       //                     BorderRadius.circular(10.0),
                              //       //                     borderSide: BorderSide(
                              //       //                         color: kMainColor, width: 1),
                              //       //                   ),
                              //       //                 ),
                              //       //                 style: TextStyle(
                              //       //                     color: Colors.black,
                              //       //                     fontSize: 14),
                              //       //                 cursorColor: kMainColor,
                              //       //                 showCursor: false,
                              //       //                 keyboardType: TextInputType.text,
                              //       //                 onChanged: (val) {
                              //       //                   setState(() => promocode = val);
                              //       //                 },
                              //       //               ),
                              //       //             ),
                              //       //             GestureDetector(
                              //       //               onTap: () {
                              //       //                 setState(() {
                              //       //                   visiblity = !visiblity;
                              //       //                   setProgressText =
                              //       //                   'Applying coupon please wait!....';
                              //       //                   showDialogBox = true;
                              //       //                   appCoupon(promocode);
                              //       //                 });
                              //       //               },
                              //       //               child: Container(
                              //       //                 alignment: Alignment.center,
                              //       //                 width: MediaQuery
                              //       //                     .of(context)
                              //       //                     .size
                              //       //                     .width *
                              //       //                     0.28,
                              //       //                 height: 40,
                              //       //                 decoration: BoxDecoration(
                              //       //                     borderRadius:
                              //       //                     BorderRadius.circular(40),
                              //       //                     color: kMainColor),
                              //       //                 child: Text(
                              //       //                   'Apply',
                              //       //                   textAlign: TextAlign.start,
                              //       //                   style: TextStyle(
                              //       //                       fontWeight: FontWeight.w300,
                              //       //                       fontSize: 15,
                              //       //                       color: kWhiteColor),
                              //       //                 ),
                              //       //               ),
                              //       //             )
                              //       //           ],
                              //       //         ),
                              //       //       )
                              //       //     ],
                              //       //   ),
                              //       // ),
                              //
                              //     ],
                              //   ),
                              // ),
                              // Container(
                              //   padding:
                              //   EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              //   color: kCardBackgroundColor,
                              //   child: Text(
                              //     'Promo Code List',
                              //     style: Theme
                              //         .of(context)
                              //         .textTheme
                              //         .caption
                              //         .copyWith(
                              //         color: kDisabledColor,
                              //         fontWeight: FontWeight.bold,
                              //         letterSpacing: 0.67),
                              //   ),
                              // ),
                              // Divider(
                              //   color: kCardBackgroundColor,
                              //   thickness: 6.7,
                              // ),
                              Visibility(
                                visible: (couponL != null && couponL.length > 0)
                                    ? true
                                    : false,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: (couponL != null && couponL.length > 0)
                                      ? ListView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          itemCount: couponL.length,
                                          itemBuilder: (context, t) {
                                            return Column(
                                              children: [
                                                Divider(
                                                  color: kCardBackgroundColor,
                                                  thickness: 2.3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            '${couponL[t].coupon_code}\n${couponL[t].coupon_description}')),
                                                    Radio(
                                                        value: t,
                                                        groupValue: radioId,
                                                        toggleable: true,
                                                        onChanged: (val) {
                                                          print('${val}');
                                                          print(
                                                              '${radioId} - ${t}');
                                                          if (radioId != t ||
                                                              radioId == -1) {
                                                            setState(() {
                                                              if (totalAmount !=
                                                                  0.0) {
                                                                radioId = t;
                                                                print(
                                                                    '${radioId} - ${t}');
                                                                setProgressText =
                                                                    'Applying coupon please wait!....';
                                                                showDialogBox =
                                                                    true;
                                                                appCoupon(couponL[
                                                                        t]
                                                                    .coupon_code);
                                                              } else {
                                                                Toast.show(
                                                                    'coupon code not applicable!',
                                                                    context,
                                                                    duration: Toast
                                                                        .LENGTH_SHORT,
                                                                    gravity: Toast
                                                                        .CENTER);
                                                              }
                                                            });
                                                          } else {
                                                            setState(() {
                                                              radioId = -1;
                                                              showDialogBox =
                                                                  true;
                                                              appCoupon(couponL[
                                                                      t]
                                                                  .coupon_code);
                                                            });
                                                          }
                                                        })
                                                  ],
                                                ),
                                                Divider(
                                                  color: kCardBackgroundColor,
                                                  thickness: 2.3,
                                                ),
                                              ],
                                            );
                                          })
                                      : Container(),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                              )
                            ],
                          ),
                        ),
                        Visibility(
                            visible: (totalAmount > 0.0) ? false : true,
                            child: Container(
                              height: 250,
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 40,
                                width: 150,
                                child: RaisedButton(
                                  onPressed: () {
                                    if (!showDialogBox) {
                                      setState(() {
                                        showDialogBox = true;
                                      });
                                      placedOrder('success', 'wallet');
                                    }
                                  },
                                  child: Text(
                                    'Place Order',
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
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: showPaymentDialog,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            color: black_color.withOpacity(0.6),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 5,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 60,
                                padding: const EdgeInsets.all(20.0),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border:
                                                const UnderlineInputBorder(),
                                            labelText: 'Card number',
                                          ),
                                          onSaved: (String value) =>
                                              _cardNumber = value,
                                        ),
                                        _verticalSizeBox,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      const UnderlineInputBorder(),
                                                  labelText: 'CVV',
                                                ),
                                                onSaved: (String value) =>
                                                    _cvv = value,
                                              ),
                                            ),
                                            _horizontalSizeBox,
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      const UnderlineInputBorder(),
                                                  labelText: 'Expiry Month',
                                                ),
                                                onSaved: (String value) =>
                                                    _expiryMonth =
                                                        int.tryParse(value),
                                              ),
                                            ),
                                            _horizontalSizeBox,
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      const UnderlineInputBorder(),
                                                  labelText: 'Expiry Year',
                                                ),
                                                onSaved: (String value) =>
                                                    _expiryYear =
                                                        int.tryParse(value),
                                              ),
                                            )
                                          ],
                                        ),
                                        _verticalSizeBox,
                                        _inProgress
                                            ? Container(
                                                alignment: Alignment.center,
                                                height: 50.0,
                                                child: Platform.isIOS
                                                    ? new CupertinoActivityIndicator()
                                                    : new CircularProgressIndicator(),
                                              )
                                            : RaisedButton(
                                                child: Text(
                                                  'Proceed to payment',
                                                  style: TextStyle(
                                                      color: kWhiteColor,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                color: kMainColor,
                                                highlightColor: kMainColor,
                                                focusColor: kMainColor,
                                                splashColor: kMainColor,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _inProgress = true;
                                                  });
                                                  _startAfreshCharge();
                                                },
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                  Positioned.fill(
                      child: Visibility(
                    visible: showDialogBox,
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        // color: black_color.withOpacity(0.6),
                        height: MediaQuery.of(context).size.height - 100,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  )),
                ],
              )),
    );
  }

  void placedOrder(paymentStatus, paymentMethod) {
    var url = pharmacy_orderplaced;
    http.post(url, body: {
      'payment_method': '${paymentMethod}',
      'wallet': iswallet ? 'yes' : 'no',
      'payment_status': paymentStatus,
      'cart_id': cart_id.toString()
    }).then((value) {
      print('deta - ${value.body}');
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          hitNavigator(cart_id, details.payment_method, details.payment_status,
              details.order_id, details.rem_price);
        } else {
          setState(() {
            showDialogBox = false;
          });
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
        }
      } else {
        setState(() {
          showDialogBox = false;
        });
        Toast.show('Something went wrong!', context,
            duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      print('error - $e');
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitNavigator(
      cart_id, payment_method, payment_status, order_id, rem_price) async {
    var url = after_order_reward_msg_new;
    http.post(url, body: {
      'cart_id': '${cart_id}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      setState(() {
        showDialogBox = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OrderPlaced(
            payment_method, payment_status, cart_id, rem_price, currency, "5");
      }));
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OrderPlaced(
            payment_method, payment_status, order_id, rem_price, currency, "5");
      }));
    });
  }

  void appCoupon(couponCode) {
    var url = applyCoupon;
    http.post(url, body: {
      'coupon_code': '$couponCode',
      'cart_id': cart_id.toString()
    }).then((value) {
      print('deta - ${value.body}');
      if (value != null && value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          setState(() {
            isCoupon = true;
            totalAmount = double.parse(details.rem_price.toString());
            coupAmount = double.parse('${details.coupon_discount}');
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount - coupAmount;
            } else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        } else if (jsonData['status'] == "2") {
          CartDetail details = CartDetail.fromJson(jsonData['data']);
          print('deta - ${details.toString()}');
          setState(() {
            isCoupon = false;
            totalAmount = double.parse(details.total_price.toString());
            coupAmount = 0.0;
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            } else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            showDialogBox = false;
          });
        } else {
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
          setState(() {
            radioId = -1;
            totalAmount = newtotalAmount;
            if (totalAmount > walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = totalAmount - walletAmount;
              walletUsedAmount = walletAmount;
            } else if (totalAmount < walletAmount) {
              if (walletAmount > 0.0) {
                iswallet = true;
              } else {
                iswallet = false;
              }
              totalAmount = 0.0;
              walletUsedAmount = newtotalAmount;
            } else {
              iswallet = false;
              walletUsedAmount = 0.0;
            }
            isCoupon = false;
            showDialogBox = false;
          });
        }
      } else {
        setState(() {
          totalAmount = newtotalAmount;
          radioId = -1;
          if (totalAmount > walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = totalAmount - walletAmount;
            walletUsedAmount = walletAmount;
          } else if (totalAmount < walletAmount) {
            if (walletAmount > 0.0) {
              iswallet = true;
            } else {
              iswallet = false;
            }
            totalAmount = 0.0;
            walletUsedAmount = newtotalAmount;
          } else {
            iswallet = false;
            walletUsedAmount = 0.0;
          }
          isCoupon = false;
          showDialogBox = false;
        });
        Toast.show('Something went wrong!', context,
            duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      print('error - $e');
      setState(() {
        totalAmount = newtotalAmount;
        radioId = -1;
        if (totalAmount > walletAmount) {
          if (walletAmount > 0.0) {
            iswallet = true;
          } else {
            iswallet = false;
          }
          totalAmount = totalAmount - walletAmount;
          walletUsedAmount = walletAmount;
        } else if (totalAmount < walletAmount) {
          if (walletAmount > 0.0) {
            iswallet = true;
          } else {
            iswallet = false;
          }
          totalAmount = 0.0;
          walletUsedAmount = newtotalAmount;
        } else {
          iswallet = false;
          walletUsedAmount = 0.0;
        }
        isCoupon = false;
        showDialogBox = false;
      });
    });
  }

  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  _startAfreshCharge() async {
    _formKey.currentState.save();

    Charge charge = Charge()
      ..amount = 100 // In base currency
      ..email = 'customer@email.com'
      ..currency = 'NGN'
      ..card = _getCardFromUI()
      ..reference = _getReference();

    _chargeCard(charge);
  }

  _chargeCard(Charge charge) async {
    PaystackPlugin.chargeCard(context, charge: charge).then((value) {
      print('${value.status}');
      print('${value.toString()}');
      print('${value.card}');
      if (value.status && value.message == "Success") {
        setState(() {
          showPaymentDialog = false;
          _inProgress = false;
          showDialogBox = true;
        });
        placedOrder("success", "Card");
      }
    });
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    placedOrder("success", "Card");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<SharedPreferences> buildAamarpayData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
