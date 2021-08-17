import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/HomeOrderAccount/Home/UI/slide_up_panel.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';
import 'package:user/bean/orderbean.dart';
import 'package:user/cancelproduct/cancelproduct.dart';

class OrderMapPage extends StatelessWidget {
  final String instruction;
  final String pageTitle;
  final OngoingOrders ongoingOrders;
  final dynamic currency;

  OrderMapPage(
      {this.instruction, this.pageTitle, this.ongoingOrders, this.currency});

  @override
  Widget build(BuildContext context) {
    return OrderMap(pageTitle, ongoingOrders, currency);
  }
}

class OrderMap extends StatefulWidget {
  final String pageTitle;
  final OngoingOrders ongoingOrders;
  final dynamic currency;

  OrderMap(this.pageTitle, this.ongoingOrders, this.currency);

  @override
  _OrderMapState createState() => _OrderMapState();
}

// Starting point latitude
double _originLatitude = 6.5212402;
// Starting point longitude
double _originLongitude = 3.3679965;
// Destination latitude
double _destLatitude = 6.849660;
// Destination Longitude
double _destLongitude = 3.648190;
// Markers to show points on the map
Map<MarkerId, Marker> markers = {};

class _OrderMapState extends State<OrderMap> {
  bool showAction = false;

  // Google Maps controller
  Completer<GoogleMapController> _controller = Completer();
  // Configure map position and zoom
  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(_originLatitude, _originLongitude),
    zoom: 9.4746,
  );

  @override
  void initState() {
    print("HELLO\n");

    /// add origin marker origin marker
    _addMarker(
      LatLng(_originLatitude, _originLongitude),
      "origin",
      BitmapDescriptor.defaultMarker,
    );

    // Add destination marker
    _addMarker(
      LatLng(_destLatitude, _destLongitude),
      "destination",
      BitmapDescriptor.defaultMarkerWithHue(90),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.ongoingOrders);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          titleSpacing: 0.0,
          title: Text(
            'Order #${widget.ongoingOrders.cart_id}',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
          actions: [
            Visibility(
              visible: (widget.ongoingOrders.order_status == 'Pending' ||
                      widget.ongoingOrders.order_status == 'Confirmed')
                  ? true
                  : false,
              child: Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CancelProduct(widget.ongoingOrders.cart_id);
                    })).then((value) {
                      if (value) {
                        setState(() {
                          widget.ongoingOrders.order_status = "Cancelled";
                        });
                      }
                    });
                  },
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
                ),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    color: white_color,
                    width: MediaQuery.of(context).size.width,
                    child: PreferredSize(
                      preferredSize: Size.fromHeight(0.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 16.3),
                                child: Image.asset(
                                  'images/maincategory/vegetables_fruitsact.png',
                                  height: 42.3,
                                  width: 33.7,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    '${widget.ongoingOrders.vendor_name}',
                                    style: orderMapAppBarTextStyle.copyWith(
                                        letterSpacing: 0.07),
                                  ),
                                  subtitle: Text(
                                    (widget.ongoingOrders.delivery_date !=
                                                "null" &&
                                            widget.ongoingOrders.time_slot !=
                                                "null" &&
                                            widget.ongoingOrders
                                                    .delivery_date !=
                                                null &&
                                            widget.ongoingOrders.time_slot !=
                                                null)
                                        ? '${widget.ongoingOrders.delivery_date} | ${widget.ongoingOrders.time_slot}'
                                        : '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(
                                            fontSize: 11.7,
                                            letterSpacing: 0.06,
                                            color: Color(0xffc1c1c1)),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${widget.ongoingOrders.order_status}',
                                        style: orderMapAppBarTextStyle.copyWith(
                                            color: kMainColor),
                                      ),
                                      SizedBox(height: 7.0),
                                      Text(
                                        '${widget.ongoingOrders.data.length} items | ${widget.currency} ${widget.ongoingOrders.price}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            .copyWith(
                                                fontSize: 11.7,
                                                letterSpacing: 0.06,
                                                color: Color(0xffc1c1c1)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: kCardBackgroundColor,
                            thickness: 1.0,
                          ),
                          Image(
                            image: AssetImage('images/logos/Delivery.gif'),
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 36.0,
                                    bottom: 6.0,
                                    top: 6.0,
                                    right: 12.0),
                                child: ImageIcon(
                                  AssetImage(
                                      'images/custom/ic_pickup_pointact.png'),
                                  size: 13.3,
                                  color: kMainColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${widget.ongoingOrders.vendor_name}\t',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          fontSize: 10.0, letterSpacing: 0.05),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 36.0,
                                    bottom: 12.0,
                                    top: 12.0,
                                    right: 12.0),
                                child: ImageIcon(
                                  AssetImage(
                                      'images/custom/ic_droppointact.png'),
                                  size: 13.3,
                                  color: kMainColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${widget.ongoingOrders.address}\t',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          fontSize: 10.0, letterSpacing: 0.05),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SlideUpPanel(widget.ongoingOrders, widget.currency),
              ],
            ),
          ),
          Container(
            height: 60.0,
            color: kCardBackgroundColor,
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${widget.ongoingOrders.data.length} items  |  ${widget.currency} ${widget.ongoingOrders.price}',
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// This method will add markers to the map based on the LatLng position
_addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
  MarkerId markerId = MarkerId(id);
  Marker marker =
      Marker(markerId: markerId, icon: descriptor, position: position);
  markers[markerId] = marker;
}
