//
//  TableViewReorderDelegate.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/22/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit


/**
 The delegate of a `ReorderController` must adopt the `TableViewReorderDelegate` protocol. This protocol defines methods for handling the reordering of rows.
 */
public protocol TableViewReorderDelegate: class {
    
    /**
     Tells the delegate that the user has moved a row from one location to another. Use this method to update your data source.
     - Parameter tableView: The table view requesting this action.
     - Parameter sourceIndexPath: The index path of the row to be moved.
     - Parameter destinationIndexPath: The index path of the row's new location.
     */
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    /**
     Asks the reorder delegate whether a given row can be moved.
     - Parameter tableView: The table view requesting this information.
     - Parameter indexPath: The index path of a row.
     */
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool
    
    /**
     Tells the delegate that the user has begun reordering a row.
     - Parameter tableView: The table view providing this information.
     */
    func tableViewDidBeginReordering(_ tableView: UITableView)
    
    /**
     Tells the delegate that the user has finished reordering.
     - Parameter tableView: The table view providing this information.
     - Parameter initialSourceIndexPath: The initial index path of the selected row, before reordering began.
     - Parameter finalDestinationIndexPath: The final index path of the selected row.
     */
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath)
    
}

public extension TableViewReorderDelegate {
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableViewDidBeginReordering(_ tableView: UITableView) {
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath:IndexPath) {
    }
    
}
