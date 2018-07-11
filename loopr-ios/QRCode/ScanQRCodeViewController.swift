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
    case undefined = "Undefined"
    
    var detectedDescription: String {
        switch self {
        case .address: return LocalizedString("Address detected", comment: "")
        case .mnemonic: return LocalizedString("Mnemonic detected", comment: "")
        case .keystore: return LocalizedString("Keystore detected", comment: "")
        case .privateKey: return LocalizedString("Private key detected", comment: "")
        case .submitOrder: return LocalizedString("Authorization message detected", comment: "")
        case .login: return LocalizedString("Login message detected", comment: "")
        case .cancelOrder: return ""
        case .convert: return ""
        case .undefined: return LocalizedString("Undefined", comment: "")
        }
    }
}

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: QRCodeScanProtocol?
    
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var scanTipLabel: UILabel!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var timer = Timer()
    var scanning: String!
    var scanLine = UIImageView()
    var scanQRCodeView = UIView()
    
    var isTorchOn = false
    var shouldPop = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Scan QR Code", comment: "")
        
        scanTipLabel.font = FontConfigManager.shared.getLabelFont()
        scanTipLabel.textColor = Themes.isNight() ? .white : .black
        scanTipLabel.text = LocalizedString("Align QR Code within Frame to Scan", comment: "")
        self.flashButton.image = UIImage(named: "TorchOff")
        
        // Get the camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        print("devices: \(deviceDiscoverySession.devices)")
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } catch {
            print(error)
            return
        }
        
        // Initialize the video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = self.scanView.layer.bounds
        self.scanView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        self.setupScanLine()
        self.setupBackGroundView()
        self.setupFrameLine()
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
        scanQRCodeView = UIView(frame: CGRect(x: scanView.frame.size.width * 0.2, y: scanView.frame.size.height * 0.2, width: scanView.frame.size.width * 0.6, height: scanView.frame.size.width * 0.6))
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
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: scanView.frame.size.width, height: scanView.frame.size.height * 0.2))
        let bottomView = UIView(frame: CGRect(x: 0, y: scanView.frame.size.height * 0.8, width: scanView.frame.size.width, height: scanView.frame.size.height * 0.2))
        let leftView = UIView(frame: CGRect(x: 0, y: scanView.frame.size.height * 0.2, width: scanView.frame.size.width * 0.2, height: scanView.frame.size.width * 0.6))
        let rightView = UIView(frame: CGRect(x: scanView.frame.size.width * 0.8, y: scanView.frame.size.height * 0.2, width: scanView.frame.size.width * 0.2, height: scanView.frame.size.width * 0.6))
        
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
        let message = LocalizedString("Do you wish to handle the qrcode?", comment: "")
        let alertPrompt = UIAlertController(title: "\(codeType.detectedDescription)", message: "\(message)", preferredStyle: .actionSheet)
        let messageAttribute = NSMutableAttributedString.init(string: alertPrompt.message!)
        messageAttribute.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)], range: NSRange(location: 0, length: (alertPrompt.message?.count)!))
        alertPrompt.setValue(messageAttribute, forKey: "attributedMessage")
        let cancelAction = UIAlertAction(title: LocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { _ in
            self.captureSession.startRunning()
        })
        let confirmAction = UIAlertAction(title: LocalizedString("Confirm", comment: ""), style: .default) { _ in
            self.delegate?.setResultOfScanningQRCode(valueSent: decodedURL, type: codeType)
            if self.shouldPop {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated: true, completion: nil)
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
    
    func qrCodeContentDetector (qrContent: String) -> QRCodeType {
        if qrContent.starts (with: "0x") {
            return QRCodeType.address
        } else if QRCodeMethod.isSubmitOrder(content: qrContent) {
            return QRCodeType.submitOrder
        } else if QRCodeMethod.isLogin(content: qrContent) {
            return QRCodeType.login
        } else if QRCodeMethod.isCancelOrder(content: qrContent) {
            return QRCodeType.cancelOrder
        } else if QRCodeMethod.isConvert(content: qrContent) {
            return QRCodeType.convert
        } else if QRCodeMethod.isMnemonicValid(mnemonic: qrContent) {
            return QRCodeType.mnemonic
        } else if QRCodeMethod.isPrivateKey(key: qrContent) {
            return QRCodeType.privateKey
        } else if QRCodeMethod.isKeystore(content: qrContent) {
            return QRCodeType.keystore
        }
        return QRCodeType.undefined
    }
}
