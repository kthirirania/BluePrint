import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BluetoothPrinter {
  static const MethodChannel _channel =
  const MethodChannel('bluetooth_printer/methodChannel');

  /*事件通道*/
  static const EventChannel _scanBlueToothEvent =
  const EventChannel('bluetooth_printer/scanBlueToothEvent');

  Stream<List<Map>> _stream;

  /*开始扫描蓝牙*/
  Future startScanBlueTooth() async {
    await _channel.invokeMethod('startScanBlueTooth');
  }

  Future<List<dynamic>> getBoundDevices() async {
    if (Platform.isIOS) return null;
    return await _channel.invokeMethod('getBoundDevices');
  }

  /*连接蓝牙设备*/
  Future<bool> connectBlueTooth(int index) async {
    int result =
    await _channel.invokeMethod('connectBlueTooth', {'index': index});
    return result == 1;
  }

  /*打印*/
  Future<int> print(Map orderInfo) async {
    int result = await _channel
        .invokeMethod('print', {'orderJsonStr': json.encode(orderInfo)});
    return result;
  }

  Future<void> testprint() async {
    await _channel.invokeMethod('testprint');
  }

  Future<void> barcodePrint() async {
    await _channel.invokeMethod('barcodePrint');
  }

  Future<bool> imagePrint(label, int index) async {
    return await _channel.invokeMethod('imagePrint', [label, index]);
  }

  /*是否已连接*/
  Future<bool> isConnected() async {
    return await _channel.invokeMethod('isConnected');
  }

  Future<void> destroy() async {
    if (Platform.isIOS) return;
    await _channel.invokeMethod('destroy');
  }

  /*监听扫描蓝牙设备回调事件*/
  Stream<List<Map>> get scanBlueToothEvent {
    if (_stream == null) {
      _stream = _scanBlueToothEvent
          .receiveBroadcastStream().map((dynamic map) =>
      Map<String,
          dynamic>.from(map));
      /*.map<Map>((data) => data).toList()*/
    }
    return _stream;
  }
}
