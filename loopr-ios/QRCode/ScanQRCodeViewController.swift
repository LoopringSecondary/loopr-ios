//
//  ScanQRCodeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScanProtocol {
    func setResultOfScanningQRCode(valueSent: String, type: QRCodeType)
}

enum QRCodeType: String {
    case address = "Address"
    case mnemonic = "Mnemonic"
    case keystore = "Keystore"
    case private_key = "Private Key"
    case undefined
}

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: QRCodeScanProtocol?
    
    @IBOutlet weak var scanView: UIView!
    
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = NSLocalizedString("QR Code", comment: "")
        
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
        
        // Initialize QR Code Frame
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.black.cgColor
            qrCodeFrameView.layer.borderWidth = 6
            self.scanView.addSubview(qrCodeFrameView)
            self.scanView.bringSubview(toFront: qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    func launchApp(decodedURL: String, code_type: QRCodeType) {
        
        if presentedViewController != nil {
            return
        }
        
        let alertPrompt = UIAlertController(title: "\(code_type.rawValue) detected", message: "\(decodedURL)", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.delegate?.setResultOfScanningQRCode(valueSent: decodedURL, type: code_type)
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        
        present(alertPrompt, animated: true, completion: nil)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if [AVMetadataObject.ObjectType.qr].contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            print("detected: \(String(describing: metadataObj.stringValue))")
        
            if metadataObj.stringValue != nil {
                let code_category = qrCodeContentDetector(qr_content: metadataObj.stringValue!)
                launchApp(decodedURL: metadataObj.stringValue!, code_type: code_category)
            }
        }
    }
    
    func qrCodeContentDetector (qr_content: String) -> QRCodeType {
        if qr_content.starts (with: "0x") {
            return QRCodeType.address
        } else if isMnemonicValid(mnemonic: qr_content) {
            return QRCodeType.mnemonic
        } else if isPrivateKey(key: qr_content) {
            return QRCodeType.private_key
        } else if isKeystore(content: qr_content) {
            return QRCodeType.keystore
        }
        
        return QRCodeType.undefined
    }
    
    func isMnemonicValid(mnemonic: String) -> Bool {
        return Mnemonic.isValid(mnemonic)
    }
    
    func isPrivateKey(key: String) -> Bool {
        
        let key_content = key.uppercased()
        
        if key_content.count != 64 {
            return false
        }
        
        for ch in key_content {
            if (ch >= "0" && ch <= "9") || (ch >= "A" && ch <= "F") {
                continue
            }
            return false
        }
        
        return true
    }
    
    func isKeystore(content: String) -> Bool {
        
        let jsonData = content.data(using: String.Encoding.utf8)
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: []) {
            if JSONSerialization.isValidJSONObject(jsonObject) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }

    }
}
