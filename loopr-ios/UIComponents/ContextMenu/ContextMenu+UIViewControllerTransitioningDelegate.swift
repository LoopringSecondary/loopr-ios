//
//  ContextMenu+UIViewControllerTransitioningDelegate.swift
//  loopr-ios
//
//  Created by sunnywheat on 3/18/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension ContextMenu: UIViewControllerTransitioningDelegate {

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let item = self.item else { return nil }
        return ContextMenuDismissing(item: item)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let item = self.item else { return nil }
        return ContextMenuPresenting(item: item)
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let item = self.item else { return nil }
        let controller = ContextMenuPresentationController(presentedViewController: presented, presenting: presenting, item: item)
        controller.contextDelegate = self
        return controller
    }

}
