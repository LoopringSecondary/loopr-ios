//
//  ContextMenu+ContextMenuPresentationControllerDelegate.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension ContextMenu: ContextMenuPresentationControllerDelegate {

    func willDismiss(presentationController: ContextMenuPresentationController) {
        guard item?.viewController === presentationController.presentedViewController else { return }
        item = nil
    }

}
