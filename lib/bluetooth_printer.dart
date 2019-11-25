import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class BluetoothPrinter {
  static const MethodChannel _channel =
  const MethodChannel('bluetooth_printer/methodChannel');

  static const EventChannel _scanBlueToothEvent =
  const EventChannel('bluetooth_printer/scanBlueToothEvent');

  BluetoothPrinter() {
    _scanBlueToothEvent
        .receiveBroadcastStream([""]).listen((dynamic data) {
          if(Platform.isAndroid) {
            final list = List<Map>.from(data);
            if (_stream != null) _stream.add(list);
          } else {
            final list = (json.decode(data) as List).map((e) => {"name": e, "address": ""}).toList();
            if (_stream != null) _stream.add(list);
          }
    });
  }

  StreamController<List<Map>> _stream;

  Future startScanBlueTooth() async {
    await _channel.invokeMethod('startScanBlueTooth');
  }

  Future<List<dynamic>> getBoundDevices() async {
    if (Platform.isIOS) return null;
    return await _channel.invokeMethod('getBoundDevices');
  }

  Future<bool> connectBlueTooth(int index) async {
    int result =
    await _channel.invokeMethod('connectBlueTooth', {'index': index});
    return result == 1;
  }

  Future<bool> print(Map orderInfo) async {
    final int res = await _channel
        .invokeMethod('print', {'orderJsonStr': json.encode(orderInfo)});
    return res == 1;
  }

  Future<void> testprint() async {
    await _channel.invokeMethod('testprint');
  }

  Future<void> barcodePrint() async {
    await _channel.invokeMethod('barcodePrint');
  }

  Future<bool> imagePrint(label, int index) async {
    final int res = await _channel.invokeMethod('imagePrint', [label, index]);
    return res == 1;
  }

  Future<bool> isConnected() async {
    final int res = await _channel.invokeMethod('isConnected');
    return res == 1;
  }

  Future<void> destroy() async {
    if (Platform.isIOS) return;
    await _channel.invokeMethod('destroy');
  }

  Stream<List<Map>> get scanBlueToothEvent {
    if (_stream == null) {
      _stream = StreamController();
    }
    return _stream.stream;
  }

  void resetStream() {
    _stream = null;
  }
}
