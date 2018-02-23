//
//  ReorderAutoScroll.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

private let autoScrollThreshold: CGFloat = 30
private let autoScrollMinVelocity: CGFloat = 60
private let autoScrollMaxVelocity: CGFloat = 280

private func mapValue(_ value: CGFloat, inRangeWithMin minA: CGFloat, max maxA: CGFloat, toRangeWithMin minB: CGFloat, max maxB: CGFloat) -> CGFloat {
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB
}

extension ReorderController {
    
    func autoScrollVelocity() -> CGFloat {
        guard let tableView = tableView, let snapshotView = snapshotView else { return 0 }
        
        guard autoScrollEnabled else { return 0 }
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(tableView.frame, tableView.scrollIndicatorInsets)
        }
        
        let distanceToTop = max(snapshotView.frame.minY - safeAreaFrame.minY, 0)
        let distanceToBottom = max(safeAreaFrame.maxY - snapshotView.frame.maxY, 0)
        
        if distanceToTop < autoScrollThreshold {
            return mapValue(distanceToTop, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: -autoScrollMinVelocity, max: -autoScrollMaxVelocity)
        }
        if distanceToBottom < autoScrollThreshold {
            return mapValue(distanceToBottom, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: autoScrollMinVelocity, max: autoScrollMaxVelocity)
        }
        return 0
    }
    
    func activateAutoScrollDisplayLink() {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        lastAutoScrollTimeStamp = nil
    }
    
    func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }
    
    @objc func handleDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        guard let tableView = tableView else { return }
        
        if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
            let scrollVelocity = autoScrollVelocity()
            
            if scrollVelocity != 0 {
                let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
                let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                
                let contentOffset = tableView.contentOffset
                tableView.contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + CGFloat(scrollDelta))
                
                let contentInset: UIEdgeInsets
                if #available(iOS 11, *) {
                    contentInset = tableView.adjustedContentInset
                } else {
                    contentInset = tableView.contentInset
                }
                
                let minContentOffset = -contentInset.top
                let maxContentOffset = tableView.contentSize.height - tableView.bounds.height + contentInset.bottom
                
                tableView.contentOffset.y = min(tableView.contentOffset.y, maxContentOffset)
                tableView.contentOffset.y = max(tableView.contentOffset.y, minContentOffset)
                
                updateSnapshotViewPosition()
                updateDestinationRow()
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
    
}

