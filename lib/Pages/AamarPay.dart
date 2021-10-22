import 'package:flutter/material.dart';
import 'package:aamarpay/aamarpay.dart';

void main() {
  runApp(MaterialApp(
    home: AamarPay(),
  ));
}

class AamarPay extends StatefulWidget {
  @override
  _AamarPayState createState() => _AamarPayState();
}

class _AamarPayState extends State<AamarPay> {
  bool isLoading = false;
  var controller = TextEditingController();
  var myamount;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: controller,
          onChanged: (v) {
            myamount = v;
            setState(() {});
            print(myamount);
          },
        ),
        Center(
          child: AamarpayData(
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
              },
              cancelUrl: "example.com/payment/cancel",
              successUrl: "example.com/payment/confirm",
              failUrl: "example.com/payment/fail",
              customerEmail: "masumbillahsanjid@gmail.com",
              customerMobile: "01834760591",
              customerName: "Masum Billah Sanjid",
              signature: "b1094e13af7b1ad5bbb55592e53ec7c7",
              storeID: "dokandar",
              transactionAmount: myamount,
              transactionID: "wtwtwt",
              description: "asgsg",
              url: "https://secure.aamarpay.com",
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      color: Colors.orange,
                      height: 50,
                      child: Center(
                          child: Text(
                        "Payment",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                    )),
        ),
      ],
    ));
  }
}
