import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:convert';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoder/services/base.dart';
import 'package:newsapp/home.dart';

void main() => runApp(new MyApp());
String url;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class AppState extends InheritedWidget {
  const AppState({
    Key key,
    this.mode,
    Widget child,
  })  : assert(mode != null),
        assert(child != null),
        super(key: key, child: child);

  final Geocoding mode;

  static AppState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppState);
  }

  @override
  bool updateShouldNotify(AppState old) => mode != old.mode;
}

class GeocodeView extends StatefulWidget {
  GeocodeView();

  @override
  _GeocodeViewState createState() => new _GeocodeViewState();
}

class _GeocodeViewState extends State<GeocodeView> {
  _GeocodeViewState();

  final TextEditingController _controller = new TextEditingController();
  var first = null;
  String cc = '';
  List<Address> results = [];

  bool isLoading = false;

  Future search() async {
    this.setState(() {
      this.isLoading = true;
    });

    try {
      var geocoding = AppState.of(context).mode;
      var result = await geocoding.findAddressesFromQuery(_controller.text);
      this.setState(() {
        cc = result.first.countryCode;
        url = "http://newsapi.org/v2/top-headlines?country=" +
            cc.toLowerCase() +
            "&excludeDomains=stackoverflow.com&sortBy=publishedAt&language=en&apiKey=18a63c0a5fa54180957213c1657d3e77";
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyApp1()));
      });
    } catch (e) {
      print("Error occured: $e");
    } finally {
      this.setState(() {
        this.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      new Card(
        child: new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    search();
                  },

                  controller: _controller,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Country Name For Latest News"),
                ),
              ),
              new IconButton(
                  icon: new Icon(Icons.search), onPressed: () => search())
            ],
          ),
        ),
      ),
      Text(
        cc,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ]);
  }
}

class _MyAppState extends State<MyApp> {
  Geocoding geocoding = Geocoder.local;

  final Map<String, Geocoding> modes = {
    "Local": Geocoder.local,
    "Google (distant)":
        Geocoder.google("AIzaSyB2k7AZOPCygLWXaAMBopnzbQIdbrGemUo"),
  };

  void _changeMode(Geocoding mode) {
    this.setState(() {
      geocoding = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new AppState(
        mode: this.geocoding,
        child: new MaterialApp(
            debugShowCheckedModeBanner: false,
            home: new DefaultTabController(
                length: 1,
                child: Scaffold(
                  appBar: AppBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 50.0,
                        ),
                        Text(
                          "World",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Ledgewood',
                              fontSize: 30.0),
                        ),
                        Text(
                          "News",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Panorama',
                              fontSize: 50.0),
                        ),
                        Text(
                          "App",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Ledgewood',
                              fontSize: 30.0),
                        )
                      ],
                    ),
                    backgroundColor: Colors.lightBlueAccent,
                    actions: <Widget>[
                      new PopupMenuButton<Geocoding>(
                        // overflow menu
                        onSelected: _changeMode,
                        itemBuilder: (BuildContext context) {
                          return modes.keys.map((String mode) {
                            return new CheckedPopupMenuItem<Geocoding>(
                              checked: modes[mode] == this.geocoding,
                              value: modes[mode],
                              child: new Text(mode),
                            );
                          }).toList();
                        },
                      ),
                    ],
                    bottom: new TabBar(
                      labelColor: Colors.white,
                      tabs: [
                        new Tab(
                          text: "Search For Country",
                          icon: new Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                  body: new TabBarView(children: <Widget>[
                    new GeocodeView(),
                  ]),
                ))));
  }
}
