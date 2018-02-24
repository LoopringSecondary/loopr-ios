//
//  ReorderDestinationRow.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - (size.width / 2), y: center.y - (size.height / 2), width: size.width, height: size.height)
    }
    
}

extension ReorderController {
    
    func updateDestinationRow() {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let newDestinationRow = newDestinationRow(),
            newDestinationRow != context.destinationRow
            else { return }
        
        var newContext = context
        newContext.destinationRow = newDestinationRow
        reorderState = .reordering(context: newContext)
        
        delegate?.tableView(tableView, reorderRowAt: context.destinationRow, to: newContext.destinationRow)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [context.destinationRow], with: .fade)
        tableView.insertRows(at: [newContext.destinationRow], with: .fade)
        tableView.endUpdates()
    }
    
    func newDestinationRow() -> IndexPath? {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let superview = tableView.superview,
            let delegate = delegate,
            let snapshotView = snapshotView
            else { return nil }
        
        let snapshotFrameInSuperview = CGRect(center: snapshotView.center, size: snapshotView.bounds.size)
        let snapshotFrame = superview.convert(snapshotFrameInSuperview, to: tableView)
        
        let visibleCells = tableView.visibleCells.filter {
            // Workaround for an iOS 11 bug.
            
            // When adding a row using UITableView.insertRows(...), if the new
            // row's frame will be partially or fully outside the table view's
            // bounds, and the new row is not the first row in the table view,
            // it's inserted without animation.
            
            let cellOverlapsTopBounds = $0.frame.minY < tableView.bounds.minY + 5
            let cellIsFirstCell = tableView.indexPath(for: $0) == IndexPath(row: 0, section: 0)
            
            return !cellOverlapsTopBounds || cellIsFirstCell
        }
        
        let rowSnapDistances = visibleCells.map { cell -> (path: IndexPath, distance: CGFloat) in
            let path = tableView.indexPath(for: cell) ?? IndexPath(row: 0, section: 0)
            
            if context.destinationRow.compare(path) == .orderedAscending {
                return (path, abs(snapshotFrame.maxY - cell.frame.maxY))
            } else {
                return (path, abs(snapshotFrame.minY - cell.frame.minY))
            }
        }
        
        let sectionIndexes = 0..<tableView.numberOfSections
        let sectionSnapDistances = sectionIndexes.flatMap { section -> (path: IndexPath, distance: CGFloat)? in
            let rowsInSection = tableView.numberOfRows(inSection: section)
            
            if section > context.destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRow(at: IndexPath(row: 0, section: section))
                }
                
                let path = IndexPath(row: 0, section: section)
                return (path, abs(snapshotFrame.maxY - rect.minY))
            } else if section < context.destinationRow.section {
                let rect: CGRect
                if rowsInSection == 0 {
                    rect = rectForEmptySection(section)
                } else {
                    rect = tableView.rectForRow(at: IndexPath(row: rowsInSection - 1, section: section))
                }
                
                let path = IndexPath(row: rowsInSection, section: section)
                return (path, abs(snapshotFrame.minY - rect.maxY))
            } else {
                return nil
            }
        }
        
        let snapDistances = rowSnapDistances + sectionSnapDistances
        let availableSnapDistances = snapDistances.filter { delegate.tableView(tableView, canReorderRowAt: $0.path) != false }
        return availableSnapDistances.min(by: { $0.distance < $1.distance })?.path
    }
    
    func rectForEmptySection(_ section: Int) -> CGRect {
        guard let tableView = tableView else { return .zero }
        
        let sectionRect = tableView.rectForHeader(inSection: section)
        return UIEdgeInsetsInsetRect(sectionRect, UIEdgeInsets(top: sectionRect.height, left: 0, bottom: 0, right: 0))
    }
    
}
