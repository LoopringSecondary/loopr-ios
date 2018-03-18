//
//  ContextMenuDelegate.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

public protocol ContextMenuDelegate: class {
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool)
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool)
}
