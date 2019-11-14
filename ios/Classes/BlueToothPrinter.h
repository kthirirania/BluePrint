//
//  BlueToothPrinter.h
//  Runner
//
//  Created by lange on 2019/10/11.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>

@interface BlueToothPrinter : NSObject
/*开始扫描蓝牙设备*/
-(void)startScanBlueTooth;
/*连接蓝牙设备*/
-(int)connectBlueTooth:(int)index;
/*打印*/
-(void)print:(NSString*)orderJsonStr;
//test print
-(void)testprint;
//barcode print
-(void)barcodePrint;
//print image
-(void)imagePrint:(UIImage*)label;
/*是否已连接蓝牙设备*/
-(int)isConnected;
@end

