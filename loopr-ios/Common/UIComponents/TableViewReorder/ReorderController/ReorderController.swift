//
//  ReorderController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

/**
 The style of the reorder spacer cell. Determines whether the cell separator line is visible.
 
 - Automatic: The style is determined based on the table view's style (plain or grouped).
 - Hidden: The spacer cell is hidden, and the separator line is not visible.
 - Transparent: The spacer cell is given a transparent background color, and the separator line is visible.
 */
public enum ReorderSpacerCellStyle {
    case automatic
    case hidden
    case transparent
}

// MARK: - ReorderController

/**
 An object that manages drag-and-drop reordering of table view cells.
 */
public class ReorderController: NSObject {
    
    // MARK: - Public interface
    
    /// The delegate of the reorder controller.
    public weak var delegate: TableViewReorderDelegate?
    
    /// Whether reordering is enabled.
    public var isEnabled: Bool = true {
        didSet { reorderGestureRecognizer.isEnabled = isEnabled }
    }
    
    public var longPressDuration: TimeInterval = 0.3 {
        didSet {
            reorderGestureRecognizer.minimumPressDuration = longPressDuration
        }
    }
    
    /// The duration of the cell selection animation.
    public var animationDuration: TimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor: UIColor = .black
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// The spacer cell style.
    public var spacerCellStyle: ReorderSpacerCellStyle = .automatic
    
    /// Whether or not autoscrolling is enabled
    public var autoScrollEnabled = true
    
    /**
     Returns a `UITableViewCell` if the table view should display a spacer cell at the given index path.
     
     Call this method at the beginning of your `tableView(_:cellForRowAt:)`, like so:
     ```
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
        return spacer
     }
     
     // ...
     }
     ```
     - Parameter indexPath: The index path
     - Returns: An optional `UITableViewCell`.
     */
    public func spacerCell(for indexPath: IndexPath) -> UITableViewCell? {
        if case let .reordering(context) = reorderState, indexPath == context.destinationRow {
            return createSpacerCell()
        }
        else if case let .ready(snapshotRow) = reorderState, indexPath == snapshotRow {
            return createSpacerCell()
        }
        return nil
    }
    
    // MARK: - Internal state
    
    struct ReorderContext {
        var sourceRow: IndexPath
        var destinationRow: IndexPath
        var snapshotOffset: CGFloat
        var touchPosition: CGPoint
    }
    
    enum ReorderState {
        case ready(snapshotRow: IndexPath?)
        case reordering(context: ReorderContext)
    }
    
    weak var tableView: UITableView?
    
    var reorderState: ReorderState = .ready(snapshotRow: nil)
    var snapshotView: UIView?
    
    var autoScrollDisplayLink: CADisplayLink?
    var lastAutoScrollTimeStamp: CFTimeInterval?
    
    lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleReorderGesture))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = self.longPressDuration
        return gestureRecognizer
    }()
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.addGestureRecognizer(reorderGestureRecognizer)
        
        reorderState = .ready(snapshotRow: nil)
    }
    
    // MARK: - Reordering
    
    func beginReorder(touchPosition: CGPoint) {
        guard case .ready = reorderState,
            let delegate = delegate,
            let tableView = tableView,
            let superview = tableView.superview
            else { return }
        
        let tableTouchPosition = superview.convert(touchPosition, to: tableView)
        
        guard let sourceRow = tableView.indexPathForRow(at: tableTouchPosition),
            delegate.tableView(tableView, canReorderRowAt: sourceRow)
            else { return }
        
        createSnapshotViewForCell(at: sourceRow)
        animateSnapshotViewIn()
        activateAutoScrollDisplayLink()
        
        tableView.reloadData()
        
        let snapshotOffset = (snapshotView?.center.y ?? 0) - touchPosition.y
        
        let context = ReorderContext(
            sourceRow: sourceRow,
            destinationRow: sourceRow,
            snapshotOffset: snapshotOffset,
            touchPosition: touchPosition
        )
        reorderState = .reordering(context: context)
        
        delegate.tableViewDidBeginReordering(tableView)
    }
    
    func updateReorder(touchPosition: CGPoint) {
        guard case .reordering(let context) = reorderState else { return }
        
        var newContext = context
        newContext.touchPosition = touchPosition
        reorderState = .reordering(context: newContext)
        
        updateSnapshotViewPosition()
        updateDestinationRow()
    }
    
    func endReorder() {
        guard case .reordering(let context) = reorderState,
            let tableView = tableView,
            let superview = tableView.superview
            else { return }
        
        reorderState = .ready(snapshotRow: context.destinationRow)
        
        let cellRectInTableView = tableView.rectForRow(at: context.destinationRow)
        let cellRect = tableView.convert(cellRectInTableView, to: superview)
        let cellRectCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
        
        // If no values change inside a UIView animation block, the completion handler is called immediately.
        // This is a workaround for that case.
        if snapshotView?.center == cellRectCenter {
            snapshotView?.center.y += 0.1
        }
        
        UIView.animate(withDuration: animationDuration,
                       animations: {
                        self.snapshotView?.center = CGPoint(x: cellRect.midX, y: cellRect.midY)
        },
                       completion: { _ in
                        if case let .ready(snapshotRow) = self.reorderState, let row = snapshotRow {
                            self.reorderState = .ready(snapshotRow: nil)
                            UIView.performWithoutAnimation {
                                tableView.reloadRows(at: [row], with: .none)
                            }
                            self.removeSnapshotView()
                        }
        }
        )
        animateSnapshotViewOut()
        clearAutoScrollDisplayLink()
        
        delegate?.tableViewDidFinishReordering(tableView, from: context.sourceRow, to: context.destinationRow)
    }
    
    // MARK: - Spacer cell
    
    private func createSpacerCell() -> UITableViewCell? {
        guard let snapshotView = snapshotView else { return nil }
        
        let cell = UITableViewCell()
        let height = snapshotView.bounds.height
        
        NSLayoutConstraint(
            item: cell,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: height
            ).isActive = true
        
        let hideCell: Bool
        switch spacerCellStyle {
        case .automatic: hideCell = tableView?.style == .grouped
        case .hidden: hideCell = true
        case .transparent: hideCell = false
        }
        
        if hideCell {
            cell.isHidden = true
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }

}
