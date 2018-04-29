//
//  QRCodeSaveToAlbum.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import Photos
import NotificationBannerSwift

class QRCodeSaveToAlbum: NSObject {
    static let albumName = "Loopring"
    static let shared = QRCodeSaveToAlbum()

    var assetCollection: PHAssetCollection!
    
    var imageNeedToBeSaved: UIImage?

    override init() {
        super.init()
        
    }
    
    func requestAccess() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (_: PHAuthorizationStatus) -> Void in
                
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            if let assetCollection = fetchAssetCollectionForAlbum() {
                self.assetCollection = assetCollection
            } else {
                self.createAlbum()
            }
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            if let assetCollection = fetchAssetCollectionForAlbum() {
                self.assetCollection = assetCollection
            } else {
                self.createAlbum()
            }
            
            if imageNeedToBeSaved != nil {
                self.save(image: imageNeedToBeSaved!)
                imageNeedToBeSaved = nil
            }
        } else {
            print("should really prompt the user to let them know it's failed")
            DispatchQueue.main.async {
                let notificationTitle = NSLocalizedString("No access to save QR code. Please go to setting to enable the access.", comment: "")
                let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
                let banner = NotificationBanner(attributedTitle: attributeString, style: .danger)
                banner.duration = 5
                banner.show()
            }
        }
    }
    
    // TO avoid duplicated album, always call fetchAssetCollectionForAlbum before create
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: QRCodeSaveToAlbum.albumName)   // create an asset collection with the album name
        }) { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
            } else {
                print("error \(error.debugDescription)")
            }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", QRCodeSaveToAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func save(image: UIImage) {
        // Try to get assets
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        }
        
        if assetCollection == nil {
            imageNeedToBeSaved = image
            // Requesting access is async call.
            requestAccess()
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        }) { (success, _) in
            if success {
                DispatchQueue.main.async {
                    let notificationTitle = NSLocalizedString("Save QR code to photo successfully.", comment: "")
                    let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                    let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
                    let banner = NotificationBanner(attributedTitle: attributeString, style: .success)
                    banner.duration = 1
                    banner.show()
                }
            } else {
                DispatchQueue.main.async {
                    let notificationTitle = NSLocalizedString("Fail to save QR code to photo", comment: "")
                    let attribute = [NSAttributedStringKey.font: UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17)!]
                    let attributeString = NSAttributedString(string: notificationTitle, attributes: attribute)
                    let banner = NotificationBanner(attributedTitle: attributeString, style: .danger)
                    banner.duration = 1
                    banner.show()
                }
            }
        }
    }

}
