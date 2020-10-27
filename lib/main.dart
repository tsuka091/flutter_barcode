import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScanPage(),
    );
  }
}

class ScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Reader'),
      ),
      body: ScanMainPage(),
    );
  }
}

class ScanMainPage extends StatefulWidget {
  @override
  _ScanMainPageState createState() => _ScanMainPageState();
}

class _ScanMainPageState extends State<ScanMainPage> {
  String _barcode = '';
  String _address = '';

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: _barcode,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text('Scan Barcode',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _barcodeScanning();
                  },
                  color: Colors.cyan,
                ),
                Text('Scan Result : $_barcode'),
                Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                FlatButton(
                  onPressed: _showResult,
                  child: Text('Show Result',
                  style: TextStyle(color: Colors.white),
                  ),
                color: Colors.cyan,
                ),
                Text('Result : $_address',
                style: TextStyle(color: Colors.white),),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _barcodeScanning() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        this._barcode = result.rawContent;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this._barcode = 'No camera permission!';
        });
      } else {
        setState(() => this._barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this._barcode = 'Nothing captured.');
    } catch (e) {
      setState(() => this._barcode = 'Unknown error: $e');
    }
  }

  void _showResult() {
    _requestGetData(int.parse(_barcode));
  }

  void _requestGetData(int id) async {
    // localhostには物理端末からは繋げないのでtimeoutでエラーになる
    http.Response response = await http.get(
        'http://localhost:3000/list/' + '$id',
        headers: {'Content-Type': 'application/json'});
    Map<String, dynamic> map = json.decode(utf8.decode(response.bodyBytes));
    var data = AddressData.fromJson(map);
    debugPrint('data| $data');
    setState(() {
      if (data.address != null) {
        _address = data.address;
      }
    });
  }
}


class AddressData extends ChangeNotifier {
  final int status;
  final int id;
  final String address;

  AddressData({this.status, this.id, this.address});

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      status: json['status'], id: json['id'], address: json['address']
    );
  }
}