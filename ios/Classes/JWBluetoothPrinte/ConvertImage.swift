import Flutter
import Foundation

class ConvertImage : NSDObject{

    static func ConvertImg (_ call FlutterMethodCall) -> UIImage {

        let imgData = call.arguments["label"] as! FlutterStandardTypedData

        let  label = UIImage(data: imgData.data)

        return label
    }

}