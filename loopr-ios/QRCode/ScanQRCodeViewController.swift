//
//  ScanQRCodeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScanProtocol: class {
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType)
}

enum QRCodeType: String {
    case address = "Address"
    case mnemonic = "Mnemonic"
    case keystore = "Keystore"
    case privateKey = "Private Key"
    case login = "UUID"
    case convert = "Convert"
    case submitOrder = "Submit Order"
    case cancelOrder = "Cancel Order"
    case p2pOrder = "P2P Order"
    case approve = "Approve"
    case undefined = "Undefined type of QRCode"
    
    var detectedDescription: String {
        switch self {
        case .address: return LocalizedString("Address detected", comment: "")
        case .mnemonic: return LocalizedString("Mnemonic detected", comment: "")
        case .keystore: return LocalizedString("Keystore detected", comment: "")
        case .privateKey: return LocalizedString("Private key detected", comment: "")
        case .submitOrder: return LocalizedString("Authorization message detected", comment: "")
        case .login: return LocalizedString("Login message detected", comment: "")
        case .cancelOrder: return LocalizedString("Cancel message detected", comment: "")
        case .convert: return LocalizedString("Convert message detected", comment: "")
        case .p2pOrder: return LocalizedString("P2P message detected", comment: "")
        case .approve: return LocalizedString("Approve", comment: "")
        case .undefined: return LocalizedString("Undefined type of QRCode", comment: "")
        }
    }
}

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var scanTipLabel: UILabel!
    @IBOutlet weak var scanTipLabelTopLayoutConstraint: NSLayoutConstraint!
    
    weak var delegate: QRCodeScanProtocol?
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var timer = Timer()
    var scanning: String!
    var scanLine = UIImageView(frame: CGRect.zero)
    var scanQRCodeView = UIView(frame: CGRect.zero)
    
    var isTorchOn = false
    var shouldPop = true
    var scanViewWidth: CGFloat = UIScreen.main.bounds.width
    
    var expectedQRCodeTypes: [QRCodeType] = [.address, .mnemonic, .keystore, .privateKey, .submitOrder, .login, .cancelOrder, .convert, .approve, .p2pOrder]

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Scan QR Code", comment: "")
        
        let albumButton = UIBarButtonItem.init(title: LocalizedString("Album", comment: ""), style: .plain, target: self, action: #selector(self.pressedAlbumButton(_:)))
        self.navigationItem.rightBarButtonItem = albumButton
        
        scanTipLabel.setTitleDigitFont()
        scanTipLabel.text = LocalizedString("Align QR code within frame to scan", comment: "")
        scanTipLabelTopLayoutConstraint.constant = scanViewWidth
        
        self.flashButton.image = UIImage(named: "TorchOff")
        
        // Get the camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        print("devices: \(deviceDiscoverySession.devices)")
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        do {
            // Initialize the video preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = self.scanView.layer.bounds
            self.scanView.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession.startRunning()
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            let x = scanViewWidth * 0.2, y = scanViewWidth * 0.2
            let scanRect = CGRect(x: x, y: y, width: scanViewWidth * 0.6, height: scanViewWidth * 0.6)
            let rectOfInterest = videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: scanRect)
            captureMetadataOutput.rectOfInterest = rectOfInterest!
        } catch {
            print(error)
            return
        }
        self.setupScanLine()
        self.setupBackGroundView()
        self.setupFrameLine()
        
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    @objc func pressedAlbumButton(_ button: UIBarButtonItem) {
        print("pressedAlbumButton")
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true) {
            
        }
    }
    
    @IBAction func switchFlash(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch && device.isTorchAvailable {
            try? device.lockForConfiguration()
            if device.torchMode == .off {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        }
        isTorchOn = !isTorchOn
        if isTorchOn {
            sender.setImage(#imageLiteral(resourceName: "TorchOn"), for: .normal)
        } else {
            sender.setImage(#imageLiteral(resourceName: "TorchOff"), for: .normal)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if scanning == "start" {
            timer.fire()
        } else {
            timer.invalidate()
        }
    }
    
    @objc func moveScannerLayer(_ timer: Timer) {
        guard captureSession.isRunning else { return }
        scanLine.frame = CGRect(x: 0, y: 0, width: self.scanQRCodeView.frame.size.width, height: 1)
        UIView.animate(withDuration: 2) {
            self.scanLine.frame = CGRect(x: self.scanLine.frame.origin.x, y: self.scanLine.frame.origin.y + self.scanQRCodeView.frame.size.height - 10, width: self.scanLine.frame.size.width, height: self.scanLine.frame.size.height)
        }
    }
    
    func setupScanLine() {
        scanQRCodeView = UIView(frame: CGRect(x: scanViewWidth * 0.2, y: scanViewWidth * 0.2, width: scanViewWidth * 0.6, height: scanViewWidth * 0.6))
        scanQRCodeView.layer.borderWidth = 1.0
        scanQRCodeView.layer.borderColor = UIColor.white.cgColor
        scanView.addSubview(scanQRCodeView)
        scanLine.frame = CGRect(x: 0, y: 0, width: scanQRCodeView.frame.size.width, height: 2)
        scanLine.image = UIImage(named: "QRCodeScanLine")
        scanQRCodeView.addSubview(scanLine)
        self.addObserver(self, forKeyPath: "scanning", options: .new, context: nil)
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveScannerLayer(_:)), userInfo: nil, repeats: true)
    }
    
    func setupBackGroundView() {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: scanViewWidth, height: scanViewWidth * 0.2))
        let leftView = UIView(frame: CGRect(x: 0, y: topView.bottomY, width: scanViewWidth * 0.2, height: scanViewWidth * 0.6))
        let bottomView = UIView(frame: CGRect(x: 0, y: leftView.bottomY, width: scanViewWidth, height: UIScreen.main.bounds.height))
        let rightView = UIView(frame: CGRect(x: scanViewWidth * 0.8, y: leftView.y, width: scanViewWidth * 0.2, height: scanViewWidth * 0.6))
        
        topView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        leftView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        rightView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        self.scanView.addSubview(topView)
        self.scanView.addSubview(bottomView)
        self.scanView.addSubview(leftView)
        self.scanView.addSubview(rightView)
    }
    
    func setupFrameLine() {
        let line = CAShapeLayer()
        let path = UIBezierPath()
        let lineLength = scanQRCodeView.frame.width * 0.1
        path.move(to: CGPoint(x: scanQRCodeView.frame.minX, y: scanQRCodeView.frame.minY + 2))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.minX + lineLength, y: scanQRCodeView.frame.minY + 2))
        path.move(to: CGPoint(x: scanQRCodeView.frame.minX + 2, y: scanQRCodeView.frame.minY))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.minX + 2, y: scanQRCodeView.frame.minY + lineLength))
        
        path.move(to: CGPoint(x: scanQRCodeView.frame.minX, y: scanQRCodeView.frame.maxY - 2))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.minX + lineLength, y: scanQRCodeView.frame.maxY - 2))
        path.move(to: CGPoint(x: scanQRCodeView.frame.minX + 2, y: scanQRCodeView.frame.maxY))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.minX + 2, y: scanQRCodeView.frame.maxY - lineLength))
        
        path.move(to: CGPoint(x: scanQRCodeView.frame.maxX, y: scanQRCodeView.frame.minY + 2))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.maxX - lineLength, y: scanQRCodeView.frame.minY + 2))
        path.move(to: CGPoint(x: scanQRCodeView.frame.maxX - 2, y: scanQRCodeView.frame.minY))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.maxX - 2, y: scanQRCodeView.frame.minY + lineLength))
        
        path.move(to: CGPoint(x: scanQRCodeView.frame.maxX, y: scanQRCodeView.frame.maxY - 2))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.maxX - lineLength, y: scanQRCodeView.frame.maxY - 2))
        path.move(to: CGPoint(x: scanQRCodeView.frame.maxX - 2, y: scanQRCodeView.frame.maxY))
        path.addLine(to: CGPoint(x: scanQRCodeView.frame.maxX - 2, y: scanQRCodeView.frame.maxY - lineLength))
        
        line.path = path.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 4
        
        line.lineJoin = kCALineJoinRound
        self.view.layer.addSublayer(line)
    }
    
    func launchApp(decodedURL: String, codeType: QRCodeType) {
        if presentedViewController != nil {
            return
        }
        guard codeType != .undefined && expectedQRCodeTypes.contains(codeType) else {
            showAlert(decodedURL: decodedURL)
            return
        }
        self.delegate?.setResultOfScanningQRCode(valueSent: decodedURL, type: codeType)
        if self.shouldPop {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            let codeCategory = qrCodeContentDetector(qrContent: stringValue)
            launchApp(decodedURL: stringValue, codeType: codeCategory)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func qrCodeContentDetector(qrContent: String) -> QRCodeType {
        if expectedQRCodeTypes.contains(.address) && QRCodeMethod.isAddress(content: qrContent) {
            return QRCodeType.address
        }

        if expectedQRCodeTypes.contains(.submitOrder) && QRCodeMethod.isSubmitOrder(content: qrContent) {
            return QRCodeType.submitOrder
        }
        
        if expectedQRCodeTypes.contains(.login) &&  QRCodeMethod.isLogin(content: qrContent) {
            return QRCodeType.login
        }
        
        if expectedQRCodeTypes.contains(.cancelOrder) && QRCodeMethod.isCancelOrder(content: qrContent) {
            return QRCodeType.cancelOrder
        }
        
        if expectedQRCodeTypes.contains(.approve) && QRCodeMethod.isApprove(content: qrContent) {
            return QRCodeType.approve
        }
        
        if expectedQRCodeTypes.contains(.convert) && QRCodeMethod.isConvert(content: qrContent) {
            return QRCodeType.convert
        }
        
        if expectedQRCodeTypes.contains(.mnemonic) && QRCodeMethod.isMnemonicValid(content: qrContent) {
            return QRCodeType.mnemonic
        }

        if expectedQRCodeTypes.contains(.privateKey) && QRCodeMethod.isPrivateKey(content: qrContent) {
            return QRCodeType.privateKey
        }
        
        if expectedQRCodeTypes.contains(.keystore) && QRCodeMethod.isKeystore(content: qrContent) {
            return QRCodeType.keystore
        }
        
        if expectedQRCodeTypes.contains(.p2pOrder) && QRCodeMethod.isP2POrder(content: qrContent) {
            return QRCodeType.p2pOrder
        }

        return QRCodeType.undefined
    }
    
    func showAlert(decodedURL: String) {
        let title = LocalizedString("QR Code type doesn't fit here", comment: "")
        let alertPrompt = UIAlertController(title: title, message: "\(decodedURL)", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { _ in
            self.captureSession.startRunning()
        })
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var stringValue: String?
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let features = detectQRCode(pickedImage), !features.isEmpty {
                for case let row as CIQRCodeFeature in features {
                    stringValue = row.messageString
                }
            }
        }
        
        dismiss(animated: true) {
            if stringValue != nil {
                self.captureSession.stopRunning()
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                let codeCategory = self.qrCodeContentDetector(qrContent: stringValue!)
                self.launchApp(decodedURL: stringValue!, codeType: codeCategory)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            
        }
    }

    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage.init(image: image) {
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)) {
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        return nil
    }

}
