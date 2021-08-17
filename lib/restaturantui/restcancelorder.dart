import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/bean/cancelbean.dart';

class CancelRestProduct extends StatefulWidget {
  final dynamic cart_id;

  CancelRestProduct(this.cart_id);

  @override
  State<StatefulWidget> createState() {
    return CancelRestProductState();
  }
}

class CancelRestProductState extends State<CancelRestProduct> {
  List<CancelProductList> cancelListPro = [];

  var idd = -1;
  String cancelDescription = '';

  bool showDialogBox = false;

  @override
  void initState() {
    super.initState();
    getCancelReasonList();
  }

  getCancelReasonList() async {
    var client = http.Client();
    var url = cancelReasonList;
    client.get(url).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && value.body != null) {
        var js = jsonDecode(value.body);
        if (js['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<CancelProductList> tagObjs = tagObjsJson
              .map((tagJson) => CancelProductList.fromJson(tagJson))
              .toList();
          if (tagObjs.length > 0) {
            setState(() {
              cancelListPro.clear();
              cancelListPro = tagObjs;
            });
          }
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
          preferredSize: Size.fromHeight(52.0),
          child: AppBar(
            titleSpacing: 0.0,
            title: Text(
              'Cancel Order Reason List',
              style: TextStyle(
                  fontSize: 18,
                  color: black_color,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${cancelListPro[index].reason}'),
                              Radio(
                                  value: index,
                                  groupValue: idd,
                                  onChanged: (value) {
                                    setState(() {
                                      idd = value;
                                    });
                                  })
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: kCardBackgroundColor,
                            height: 2,
                          );
                        },
                        itemCount: cancelListPro.length),
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cancelDescription = value;
                      });
                    },
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Describe cancelling reason',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: kWhiteColor, fontWeight: FontWeight.w400),
                      ),
                      color: kMainColor,
                      highlightColor: kMainColor,
                      focusColor: kMainColor,
                      splashColor: kMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        setState(() {
                          showDialogBox = true;
                        });
                        if (idd == -1) {
                          Toast.show(
                              'Please select a reason to cancel the product!',
                              context,
                              duration: Toast.LENGTH_SHORT);
                        } else {
                          hitService('${cancelListPro[idd].reason}', context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
                child: Visibility(
              visible: showDialogBox,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 100,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        color: white_color,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Loading please wait!....',
                              style: TextStyle(
                                  color: kMainTextColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ],
        ));
  }

  void hitService(String s, BuildContext context) {
    var client = http.Client();
    var url = order_cancel;
    client.post(url, body: {
      'reason': '${s}',
      'cart_id': '${widget.cart_id}',
      'description': cancelDescription
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && value.body != null) {
        var js = jsonDecode(value.body);
        if (js['status'] == "1") {
          Toast.show(js['message'], context, duration: Toast.LENGTH_SHORT);
          Navigator.of(context).pop(true);
        } else {
          Toast.show('Prodcut not canceled.', context,
              duration: Toast.LENGTH_SHORT);
        }
      }
      setState(() {
        showDialogBox = false;
      });
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }
}