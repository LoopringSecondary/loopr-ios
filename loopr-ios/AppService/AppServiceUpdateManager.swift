//
//  AppServiceManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 10/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class AppServiceUpdateManager {
    
    static let shared = AppServiceUpdateManager()

    var latestBuildVersion: String = "0.0.1"
    var latestBuildDescription: String?
    
    private init() {
        
    }

    // Current build version
    func getBuildVersion() -> String {
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return build
    }

    func getAppVersionAndBuildVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return version + " (" + build + ")"
    }

    func getLatestAppVersion(completion: @escaping (_ shouldDisplayUpdateNotification: Bool) -> Void) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier, bundleIdentifier == "leaf.prod.app" else {
            return
        }
        
        // Seprate from Request.
        let url = URL(string: "https://www.loopring.mobi/rpc/v1/version/ios/getLatest")
        let task = URLSession.shared.dataTask(with: url! as URL) { data, _, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            let json = JSON(data)
            let latestBuildVersion = json["message"]["version"].string ?? "0.0.1"
            let currentBuildVersion = self.getBuildVersion()
            let largestSkipBuildVersion = self.getLargestSkipBuildVersion()
            if latestBuildVersion.compare(currentBuildVersion, options: .numeric) == .orderedDescending && latestBuildVersion != currentBuildVersion && latestBuildVersion.compare(largestSkipBuildVersion, options: .numeric) == .orderedDescending && latestBuildVersion != largestSkipBuildVersion {
                print("latestBuildVersion version is newer")
                self.latestBuildVersion = latestBuildVersion
                self.latestBuildDescription = json["message"]["description"].string
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    func getLargestSkipBuildVersion() -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: UserDefaultsKeys.largestSkipBuildVersion.rawValue) ?? "0.0.1"
    }

    func setLargestSkipBuildVersion() {
        let defaults = UserDefaults.standard
        defaults.set(latestBuildVersion, forKey: UserDefaultsKeys.largestSkipBuildVersion.rawValue)
    }

}
