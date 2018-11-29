//
//  MarketDetailViewControllerSwipe.swift
//  loopr-ios
//
//  Created by Ruby on 11/29/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

extension MarketDetailViewController {
    
    func getHeightForHeaderInSwipeSection() -> CGFloat {
        // Get this value from SwipeViewOptions.getDefault()
        return 59
    }
    
    func getHeaderViewInSwipeSection() -> UIView {
        marketDetailSwipeViewController.market = market
        marketDetailSwipeViewController.delegate = self
        return marketDetailSwipeViewController.view
    }

}

extension MarketDetailViewController: MarketDetailSwipeViewControllerDelegate {

    func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        swipeViewIndex = toIndex
        self.tableView.reloadData()
    }

}
