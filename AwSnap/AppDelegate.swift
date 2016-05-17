import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    private var _device:AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
    private var _session:AVCaptureSession = AVCaptureSession()
    private var _capture:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    private var _layer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    private var _count:Int32 = 0

    /* ====================================================================== */
    /* NSApplicationDelegate                                                  */
    /* ====================================================================== */

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        if _device != nil {

            // Position the window smack in the middle of the screen
            let description = _device!.activeFormat.formatDescription
            let dimensions:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)

            let width = CGFloat(dimensions.width)
            let height = CGFloat(dimensions.height)

            let screen = window.screen!.frame

            let x = (screen.width - width) / 2
            let y = (screen.height - height) / 2

            let frame = NSRect(x: x, y: y, width: width, height: height)
            window.setFrame(frame, display: true, animate: false)

            // Start the preview
            preview();
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
    /* Device Selection                                                       */
    /* ====================================================================== */

    func switchDevice(sender:NSMenuItem) {
        let device:AVCaptureDevice = sender.representedObject as! AVCaptureDevice
        NSLog("Selecting device: " + device.localizedName)
        _device = device
        preview()
    }

    @IBAction func selectDevice(sender:NSButton) {

        let menu = NSMenu()
        menu.autoenablesItems = false

        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            let item = menu.addItemWithTitle(device.localizedName, action: #selector(switchDevice), keyEquivalent: "")
            if device.isEqualTo(_device) {
                item?.state = NSOnState
                item?.enabled = false
            }
            item?.representedObject = device
            item?.target = self
        }

        let event:NSEvent? = NSApplication.sharedApplication().currentEvent
        NSMenu.popUpContextMenu(menu, withEvent: event!, forView: sender)
    }

    /* ====================================================================== */
    /* Format Selection                                                       */
    /* ====================================================================== */

    func switchFormat(sender:NSMenuItem) {
        let format:AVCaptureDeviceFormat = sender.representedObject as! AVCaptureDeviceFormat
        NSLog("Selecting format: " + format.localizedName)

        // Reconfigure the format and rescale the window
        do {
            try _device!.lockForConfiguration()
            _device!.activeFormat = format
            _device!.unlockForConfiguration()
            resize()
        } catch let error as NSError {
            NSLog("Error configuring: %@", error.localizedDescription);
        }
    }

    @IBAction func selectFormat(sender:NSButton) {
        if _device == nil { return }

        let menu = NSMenu()
        menu.autoenablesItems = false

        for format in _device!.formats {
            if (CMFormatDescriptionGetMediaType(format.formatDescription) == kCMMediaType_Video) {
                let item = menu.addItemWithTitle(format.localizedName, action: #selector(switchFormat), keyEquivalent: "")
                if format.isEqualTo(_device!.activeFormat) {
                    item?.state = NSOnState
                    item?.enabled = false
                }
                item?.representedObject = format
                item?.target = self
            }
        }

        let event:NSEvent? = NSApplication.sharedApplication().currentEvent
        NSMenu.popUpContextMenu(menu, withEvent: event!, forView: sender)
    }
    

    /* ====================================================================== */

    @IBAction func takePicture(sender:NSButton) {
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
    /* Preview and resizing                                                   */
    /* ====================================================================== */

    func preview() {
        // Stop, clear and recreate session
        _session.stopRunning()
        _session.removeOutput(_capture)
        _session = AVCaptureSession()

        do {
            // Create input and add it to the session
            let input:AVCaptureInput = try AVCaptureDeviceInput(device:_device)
            _session.addInput(input)

            // Create output and add it to the session
            _capture.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
            _session.addOutput(_capture)

            // Remove everything from the preview layer
            let previewLayer:CALayer = window.contentView!.layer!
            if (previewLayer.sublayers?.first is AVCaptureVideoPreviewLayer) {
                NSLog("Replacing preview layer");
                previewLayer.sublayers?.removeFirst()
            } else {
                NSLog("Appending preview layer");
            }

            // Add our new preview layer
            let videoLayer = AVCaptureVideoPreviewLayer(session: _session)
            videoLayer.frame = previewLayer.bounds
            videoLayer.autoresizingMask = CAAutoresizingMask.LayerWidthSizable.union(CAAutoresizingMask.LayerHeightSizable)
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer.insertSublayer(videoLayer, atIndex: 0)

            // Start the preview session
            resize()
            _session.startRunning()
        } catch let error as NSError {
            NSLog("Error creating session: %@", error.localizedDescription);
        }

    }

    private func resize() {
        if _device == nil { return }

        let description = _device!.activeFormat.formatDescription
        let dimensions:CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(description)

        let x = window.frame.origin.x
        let width = CGFloat(dimensions.width < 240 ? 240 : dimensions.width)
        let height = CGFloat(dimensions.height < 160 ? 160 : dimensions.height)

        let y = window.frame.origin.y + window.frame.size.height - height

        let frame = NSRect(x: x, y: y, width: width, height: height)

        window.setFrame(frame, display: true, animate: true)
    }
}

