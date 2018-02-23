//
//  ReorderGestureRecognizer.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//


import UIKit

extension ReorderController {
    
    @objc internal func handleReorderGesture(_ gestureRecognizer: UIGestureRecognizer) {
        guard let superview = tableView?.superview else { return }
        
        let touchPosition = gestureRecognizer.location(in: superview)
        
        switch gestureRecognizer.state {
        case .began:
            beginReorder(touchPosition: touchPosition)
            
        case .changed:
            updateReorder(touchPosition: touchPosition)
            
        case .ended, .cancelled, .failed, .possible:
            endReorder()
        }
    }
    
}

extension ReorderController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let tableView = tableView else { return false }
        
        let gestureLocation = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: gestureLocation) else { return false }
        
        return delegate?.tableView(tableView, canReorderRowAt: indexPath) ?? true
    }
    
}

