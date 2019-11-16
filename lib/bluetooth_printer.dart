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

  /*开始扫描蓝牙*/
  Future startScanBlueTooth() async {
    await _channel.invokeMethod('startScanBlueTooth');
  }
  Future<List<dynamic>> getBoundDevices() async {
    if(Platform.isIOS) return null;
    return await _channel.invokeMethod('getBoundDevices');
  }

  /*连接蓝牙设备*/
  Future<bool> connectBlueTooth(int index) async {
    int result =
        await _channel.invokeMethod('connectBlueTooth', {'index': index});
    return result==1;
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

  Future<bool> imagePrint(label) async {
    return await _channel.invokeMethod('imagePrint', [label]);
  }

  /*是否已连接*/
  Future<bool> isConnected() async {
    int result = await _channel.invokeMethod('isConnected');
    return result == 1;
  }

  Future<void> destroy() async {
    if(Platform.isIOS) return;
    await _channel.invokeMethod('destroy');
  }

  /*监听扫描蓝牙设备回调事件*/
  Stream<List<dynamic>> get scanBlueToothEvent => _scanBlueToothEvent
      .receiveBroadcastStream()
      .map((data) => json.decode(data));
}
