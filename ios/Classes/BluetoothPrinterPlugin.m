#import "BluetoothPrinterPlugin.h"
#import "BlueToothPrinter.h"
#import "ScanBlueToothEvent.h"
//#import "ConvertImage-Swift.h"

@implementation BluetoothPrinterPlugin{
     BlueToothPrinter *blueToothPrinter;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    /*方法通道*/
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"bluetooth_printer/methodChannel"
                                     binaryMessenger:[registrar messenger]];
    BluetoothPrinterPlugin* instance = [[BluetoothPrinterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    /*事件通道*/
    FlutterEventChannel* eventChannle = [FlutterEventChannel eventChannelWithName:@"bluetooth_printer/scanBlueToothEvent" binaryMessenger:[registrar messenger]];
    ScanBlueToothEvent *scanBlueToothEvent=[[ScanBlueToothEvent alloc]init];
    [eventChannle setStreamHandler:scanBlueToothEvent];

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if(!blueToothPrinter){
        blueToothPrinter =[[BlueToothPrinter alloc]init];
    }
    if([@"startScanBlueTooth" isEqualToString:call.method]){
        [blueToothPrinter startScanBlueTooth];
    }
    else if([@"connectBlueTooth" isEqualToString:call.method]){
        int index = [call.arguments[@"index"] intValue];
        [blueToothPrinter connectBlueTooth:index];
        result(@(1));
    }else if([@"print" isEqualToString:call.method]){
        NSString * orderJsonStr = call.arguments[@"orderJsonStr"];
        [blueToothPrinter print:orderJsonStr];
        result(@(1));

    }else if([@"isConnected" isEqualToString:call.method]){
        int r = [blueToothPrinter isConnected];
        result(@(r));

    }else if([@"testprint" isEqualToString:call.method]){
             [blueToothPrinter testprint];

    }else if([@"imagePrint" isEqualToString:call.method]){
    	NSArray *args = call.arguments;
    	FlutterStandardTypedData *list = args[0];
        UIImage *label = [UIImage imageWithData:list.data];
        NSNumber *quantity = args[1];
        
        if((quantity == nil) || (quantity.intValue == 0)){
             [blueToothPrinter imagePrint:label];
        }else{
            for(int i = 0; i < quantity.intValue; i++) {
                [blueToothPrinter imagePrint:label];
            }
        }
        result(@(1));

    }else if([@"barcodePrint" isEqualToString:call.method]){
              [blueToothPrinter barcodePrint];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end

