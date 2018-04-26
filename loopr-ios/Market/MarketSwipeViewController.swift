//
//  MarketSwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MarketSwipeViewController: SwipeViewController, UISearchBarDelegate {
    
    private var type: MarketSwipeViewType = .favorite
    private var types: [MarketSwipeViewType] = []
    private var viewControllers: [MarketViewController] = []
    
    var options = SwipeViewOptions()
    
    let searchBar = UISearchBar()
    let orderHistoryButton = UIButton(type: UIButtonType.custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.theme_backgroundColor = GlobalPicker.backgroundColor

        setupSearchBar()
        // self.navigationItem.title = NSLocalizedString("Market", comment: "")
        
        setupChildViewControllers()

        let image = UIImage(named: "Order-history-black")
        orderHistoryButton.setBackgroundImage(image, for: .normal)
        orderHistoryButton.setBackgroundImage(image?.alpha(0.3), for: .highlighted)
        
        orderHistoryButton.addTarget(self, action: #selector(self.pressOrderHistoryButton(_:)), for: UIControlEvents.touchUpInside)
        orderHistoryButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)

        let orderHistoryBarButton = UIBarButtonItem(customView: orderHistoryButton)
        self.navigationItem.rightBarButtonItem = orderHistoryBarButton
        
        // getOrdersFromServer should be here. MarketSwipeViewController has four MarketViewController.
        // If it's in the MarketViewController, getOrdersFromServer will be called four times.
        OrderDataManager.shared.getOrdersFromServer()
    }
    
    func setupChildViewControllers() {
        types = [.favorite, .ETH, .LRC, .all]
        
        let vc0 = MarketViewController(type: .favorite)
        vc0.didSelectRowClosure = { (market) -> Void in
            
        }

        let vc1 = MarketViewController(type: .ETH)
        vc1.didSelectRowClosure = { (market) -> Void in
            
        }
        
        let vc2 = MarketViewController(type: .LRC)
        vc2.didSelectRowClosure = { (market) -> Void in
            
        }
        
        let vc3 = MarketViewController(type: .all)
        vc3.didSelectRowClosure = { (market) -> Void in
            
        }
        
        viewControllers = [vc0, vc1, vc2, vc3]
        for viewController in viewControllers {
            self.addChildViewController(viewController)
        }
        viewControllers[0].viewAppear = true
        
        options.swipeTabView.height = 44
        options.swipeTabView.underlineView.height = 1
        options.swipeTabView.underlineView.margin = 20
        
        // TODO: needsAdjustItemViewWidth will trigger expensive computation.
        // options.swipeTabView.needsAdjustItemViewWidth = false
        
        // TODO: .segmented will disable the value of width
        options.swipeTabView.style = .segmented
        
        options.swipeTabView.itemView.font = UIFont.init(name: FontConfigManager.shared.getRegular(), size: 17) ?? UIFont.systemFont(ofSize: 17)
        
        // This conflicts to the swipe action in the table view cell.
        options.swipeContentScrollView.isScrollEnabled = false
        
        swipeView.reloadData(options: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        searchBar.showsCancelButton = false
        
        // TODO: no reload data in the viewWIllAppear. Need to implement the night mode.
        if Themes.isNight() {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.white
            // swipeView.reloadData(options: options, default: swipeView.currentIndex)
        } else {
            options.swipeTabView.itemView.textColor = UIColor.init(white: 0.5, alpha: 1)
            options.swipeTabView.itemView.selectedTextColor = UIColor.black
            // swipeView.reloadData(options: options, default: swipeView.currentIndex)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        searchBar.searchBarStyle = .minimal

        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
    }

    @objc func pressOrderHistoryButton(_ button: UIBarButtonItem) {
        print("pressOrderHistoryButton")
        let viewController = OrderHistoryViewController()
        viewController.orders = OrderDataManager.shared.getDataOrders(tokenSymbol: nil)
        viewController.hidesBottomBarWhenPushed = true
        
        // Set endEnditing to true, otherwise the keyboard will trigger a wired animation.
        navigationController?.view.endEditing(true)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Delegate
    override func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) {
        // print("will setup SwipeView")
    }
    
    override func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) {
        // print("did setup SwipeView")
    }

    override func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // print("will change from item \(fromIndex) to item \(toIndex)")
        var isFiltering: Bool = false
        let searchText = searchBar.text ?? ""
        if searchText.trim() != "" {
            isFiltering = true
        }

        type = types[toIndex]
        let viewController = viewControllers[toIndex]
        viewController.reload(isFiltering: isFiltering, searchText: searchText)
    }

    override func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        // print("did change from item \(fromIndex) to section \(toIndex)")
        viewControllers[fromIndex].viewAppear = false
        viewControllers[toIndex].viewAppear = true
    }

    // MARK: - DataSource
    override func numberOfPages(in swipeView: SwipeView) -> Int {
        return viewControllers.count
    }
    
    override func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return types[index].rawValue
    }

    override func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }

    // MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchBar textDidChange \(searchText) \(self.swipeView.currentIndex)")
        
        viewControllers[self.swipeView.currentIndex].searchTextDidUpdate(searchText: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarCancelButtonClicked")
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        let orderHistoryBarButton = UIBarButtonItem(customView: orderHistoryButton)
        self.navigationItem.rightBarButtonItem = orderHistoryBarButton
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidBeginEditing")
        searchBar.showsCancelButton = true
        self.navigationItem.rightBarButtonItem = nil
        searchBar.becomeFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("searchBarTextDidEndEditing")
    }
}
