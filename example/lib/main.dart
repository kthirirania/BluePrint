import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:bluetooth_printer/bluetooth_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothPrinter bluetoothPrinter;

  GlobalKey globalKey = GlobalKey();

  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 1.50);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    //print(pngBytes);

    bluetoothPrinter.imagePrint(pngBytes, 1);
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    bluetoothPrinter = new BluetoothPrinter();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    bluetoothPrinter.scanBlueToothEvent.listen((data) async {
                      print('listent data = $data');
                    });
                    bluetoothPrinter.startScanBlueTooth();
                  }),
              IconButton(
                icon: Icon(Icons.bluetooth_connected),
                onPressed: () async {
                  bluetoothPrinter.connectBlueTooth(0).then((result) {
                    print("connected result $result");
                  });
                  bool b = await bluetoothPrinter.isConnected();
                  print('isConnected:$b');
                },
              ),
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () {
                  bluetoothPrinter.barcodePrint();
                },
              ),
              InkWell(
                child: SizedBox(
                    height: 210,
                    width: 280, // old 260
                    child: RepaintBoundary(
                      key: globalKey,
                      child: MemberProductLabel(),
                    )),
                onTap: () async => await _capturePng(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemberProductLabel extends StatelessWidget {
  final String text;
  final double height;
  final double lineWidth;

  MemberProductLabel(
      {Key key,
      this.text = "(con cart)",
      this.height = 80,
      this.lineWidth = 1.3})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
//      height: 200,
//      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              "Product Test 1",
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 2.0,
            color: Colors.black,
            margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          ),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Siyou Tech",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  BarCodeImage(
                    padding: EdgeInsets.all(8.0),
                    hasText: true,
                    data: "2010030002880",
                    codeType: BarCodeType.CodeEAN13,
                    barHeight: height,
                    lineWidth: lineWidth,
                    onError: (error) {
                      print('error = $error');
                    },
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "\€ 1,99",
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 34.0),
                      textAlign: TextAlign.center,
                    ),
                    Text(text),
                    SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      "\€ 1,49",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 28.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
