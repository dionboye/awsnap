import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var settings: NSWindow!
    @IBOutlet weak var click: NSButton!

    private var _session:AVCaptureSession = AVCaptureSession()
    private var _capture:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    private var _count:Int32 = 0

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Get our device
        let device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

        // Position the window smack in the middle of the screen
        let description = device.activeFormat.formatDescription
        let dimensions:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)

        let width = CGFloat(dimensions.width)
        let height = CGFloat(dimensions.height)

        let screen = window.screen!.frame

        let x = (screen.width - width) / 2
        let y = (screen.height - height) / 2

        let frame = NSRect(x: x, y: y, width: width, height: height)
        window.setFrame(frame, display: true, animate: false)

        // Start the preview
        do {
            let input:AVCaptureInput = try AVCaptureDeviceInput(device:device)
            _session.addInput(input)

            _capture.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
            _session.addOutput(_capture)

            let previewLayer:CALayer = view.layer!

            let videoLayer = AVCaptureVideoPreviewLayer(session: _session)
            videoLayer.frame = previewLayer.bounds
            videoLayer.autoresizingMask = CAAutoresizingMask.LayerWidthSizable.union(CAAutoresizingMask.LayerHeightSizable)
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

            previewLayer.insertSublayer(videoLayer, atIndex: 0)

            _session.startRunning()
        } catch let error as NSError {
            NSLog("Error creating session: %@", error.localizedDescription);
        }

        // Bring the window up front
        window.makeKeyAndOrderFront(window)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        _session.stopRunning()
    }

    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication) -> Bool {
        return true;
    }


    /* ====================================================================== */

    @IBAction func clickSettings(sender:NSButton) {
        if settings.visible { return }
        settings.setFrameTopLeftPoint(NSEvent.mouseLocation())
        settings.makeKeyAndOrderFront(sender)
    }

    @IBAction func clickCamera(sender:NSButton) {
        if _capture.connections.count < 1 {
            NSLog("No connections to capture");
            return
        }

        let connection:AVCaptureConnection = _capture.connections.first as! AVCaptureConnection
        _capture.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (buffer, error) in
            if (error != nil) {
                NSLog("Error capturing %@", error)
            } else {
                let data:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)

                let pictures = NSString(string:NSHomeDirectory()).stringByAppendingPathComponent("Pictures")
                let directory = NSString(string:pictures).stringByAppendingPathComponent("Aw Snap")

                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    NSLog("Error creating directory: %@", error);
                }


                let formatter = NSDateFormatter()
                self._count = self._count + 1
                formatter.dateFormat = String(format: "yyyyMMdd-HHmmss-'%04d.jpg'", self._count)
                let date = formatter.stringFromDate(NSDate())
                let path = NSString(string:directory).stringByAppendingPathComponent(date)

                NSLog("Writing %d bytes to %@", data.length, path);

                if data.writeToFile(path, atomically: true) { return }
                NSLog("Unable to write %d bytes to %@", data.length, path);
            }
        })
    }

    /* ====================================================================== */

    private var _selectedDevice:AVCaptureDevice? = nil;

    var availableDevices:[AVCaptureDevice] {
        get {
            let devices:[AnyObject] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            return devices as! [AVCaptureDevice]
        }
    }

    var selectedDevice:AVCaptureDevice? {
        get {
            if (_selectedDevice == nil) {
                _selectedDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            }
            return _selectedDevice
        }
        set {
            NSLog("Selected %@", newValue == nil ? "[nil]" : newValue!.localizedName)
            _selectedDevice = newValue
            rere()
        }
    }

    var availableFormats:[AVCaptureDeviceFormat] {
        get {
            let device:AVCaptureDevice? = self.selectedDevice
            if device == nil { return [] }

            let formats:[AnyObject]? = device!.formats
            if formats == nil { return [] }

            return formats as! [AVCaptureDeviceFormat]
        }
    }

    var selectedFormat:AVCaptureDeviceFormat? {
        get {
            if _selectedDevice == nil { return nil }
            return _selectedDevice!.activeFormat
        }
        set {
            NSLog("Selected %@", newValue == nil ? "[nil]" : newValue!.localizedName)
            if (newValue != nil) && (_selectedDevice != nil) {
                do {
                    try _selectedDevice!.lockForConfiguration()
                    _selectedDevice!.activeFormat = newValue
                    _selectedDevice!.unlockForConfiguration()
                    rere()
                } catch let error as NSError {
                    NSLog("Error configuring: %@", error.localizedDescription);
                }
            }
        }
    }

    private func rere() {
        if _selectedDevice == nil { return }

        let description = _selectedDevice!.activeFormat.formatDescription
        let dimensions:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)

        let x = window.frame.origin.x
        let width = CGFloat(dimensions.width)
        let height = CGFloat(dimensions.height)

        let y = window.frame.origin.y + window.frame.size.height - height

        let frame = NSRect(x: x, y: y, width: width, height: height)

        window.setFrame(frame, display: true, animate: true)
    }
}

