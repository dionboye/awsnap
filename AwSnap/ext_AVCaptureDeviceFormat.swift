import Cocoa
import AVFoundation

extension AVCaptureDeviceFormat {
    var localizedName:String {
        get {
            let description = self.formatDescription

            if (CMFormatDescriptionGetMediaType(description) == kCMMediaType_Video) {
                let formatName = CMFormatDescriptionGetExtension(description, kCMFormatDescriptionExtension_FormatName) as! NSString
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                return String(format: "%@ (%d x %d)", formatName, dimensions.width, dimensions.height)
            }
            return "Unsupported/unkonwn format"
        }
    }
}
