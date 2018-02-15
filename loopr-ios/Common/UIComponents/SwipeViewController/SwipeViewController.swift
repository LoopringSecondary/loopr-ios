//
//  SwipeViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

open class SwipeViewController: UIViewController, SwipeViewDelegate, SwipeViewDataSource {
    
    open var swipeView: SwipeView!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeView = SwipeView(frame: view.frame)
        swipeView.delegate = self
        swipeView.dataSource = self
        view.addSubview(swipeView)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        swipeView.willChangeOrientation()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addSwipeViewConstraints()
    }
    
    private func addSwipeViewConstraints() {
        swipeView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *), view.hasSafeAreaInsets, swipeView.options.swipeTabView.isSafeAreaEnabled {
            NSLayoutConstraint.activate([
                swipeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                swipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                swipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                swipeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([
                swipeView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor),
                swipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                swipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                swipeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        }
    }
    
    // MARK: - SwipeViewDelegate
    open func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) { }
    open func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) { }
    open func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    open func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    
    // MARK: - SwipeViewDataSource
    open func numberOfPages(in swipeView: SwipeView) -> Int {
        return 0
    }
    
    open func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String {
        return ""
    }
    
    open func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController {
        return UIViewController()
    }

}

