//
//  ReorderSnapshotView.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension ReorderController {
    
    func createSnapshotViewForCell(at indexPath: IndexPath) {
        guard let tableView = tableView, let superview = tableView.superview else { return }
        
        removeSnapshotView()
        tableView.reloadData()
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let cellFrame = tableView.convert(cell.frame, to: superview)
        
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let cellImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let view = UIImageView(image: cellImage)
        view.frame = cellFrame
        
        view.layer.masksToBounds = false
        view.layer.opacity = Float(cellOpacity)
        view.layer.transform = CATransform3DMakeScale(cellScale, cellScale, 1)
        
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOpacity = Float(shadowOpacity)
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowOffset = shadowOffset
        
        superview.addSubview(view)
        snapshotView = view
    }
    
    func removeSnapshotView() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
    }
    
    func updateSnapshotViewPosition() {
        guard case .reordering(let context) = reorderState, let tableView = tableView else { return }
        
        var newCenterY = context.touchPosition.y + context.snapshotOffset
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.scrollIndicatorInsets)
        }
        
        newCenterY = min(newCenterY, safeAreaFrame.maxY)
        newCenterY = max(newCenterY, safeAreaFrame.minY)
        
        snapshotView?.center.y = newCenterY
    }
    
    func animateSnapshotViewIn() {
        guard let snapshotView = snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = cellOpacity
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = 0
        shadowAnimation.toValue = shadowOpacity
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = 1
        transformAnimation.toValue = cellScale
        transformAnimation.duration = animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
    }
    
    func animateSnapshotViewOut() {
        guard let snapshotView = snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = cellOpacity
        opacityAnimation.toValue = 1
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = shadowOpacity
        shadowAnimation.toValue = 0
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = cellScale
        transformAnimation.toValue = 1
        transformAnimation.duration = animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
        
        snapshotView.layer.opacity = 1
        snapshotView.layer.shadowOpacity = 0
        snapshotView.layer.transform = CATransform3DIdentity
    }
    
}
