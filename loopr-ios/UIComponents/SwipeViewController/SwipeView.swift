//
//  SwipeView.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/14/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

// MARK: - SwipeViewDelegate

public protocol SwipeViewDelegate: class {
    
    /// Called before setup self.
    func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int)
    
    /// Called after setup self.
    func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int)
    
    /// Called before swiping the page.
    func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int)
    
    /// Called after swiping the page.
    func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int)
}

extension SwipeViewDelegate {
    public func swipeView(_ swipeView: SwipeView, viewWillSetupAt currentIndex: Int) { }
    public func swipeView(_ swipeView: SwipeView, viewDidSetupAt currentIndex: Int) { }
    public func swipeView(_ swipeView: SwipeView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    public func swipeView(_ swipeView: SwipeView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
}

// MARK: - SwipeViewDataSource

public protocol SwipeViewDataSource: class {
    
    /// Return the number of pages in `SwipeView`.
    func numberOfPages(in swipeView: SwipeView) -> Int
    
    /// Return strings to be displayed at the specified tag in `SwipeView`.
    func swipeView(_ swipeView: SwipeView, titleForPageAt index: Int) -> String
    
    /// Return a ViewController to be displayed at the specified page in `SwipeView`.
    func swipeView(_ swipeView: SwipeView, viewControllerForPageAt index: Int) -> UIViewController
}

// MARK: - SwipeView

open class SwipeView: UIView {
    
    /// An object conforms `SwipeViewDelegate`. Provide views to populate the `SwipeView`.
    open weak var delegate: SwipeViewDelegate?
    
    /// An object conforms `SwipeViewDataSource`. Provide views and respond to `SwipeView` events.
    open weak var dataSource: SwipeViewDataSource?
    
    open fileprivate(set) var swipeTabView: SwipeTabView? {
        didSet {
            guard let swipeTabView = swipeTabView else { return }
            swipeTabView.dataSource = self
            addSubview(swipeTabView)
            layout(swipeTabView: swipeTabView)
        }
    }
    
    open fileprivate(set) var swipeContentScrollView: SwipeContentScrollView? {
        didSet {
            guard let swipeContentScrollView = swipeContentScrollView else { return }
            swipeContentScrollView.delegate = self
            swipeContentScrollView.dataSource = self
            addSubview(swipeContentScrollView)
            layout(swipeContentScrollView: swipeContentScrollView)
        }
    }
    
    public var options: SwipeViewOptions
    
    fileprivate var isLayoutingSubviews: Bool = false
    
    fileprivate var pageCount: Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }
    
    fileprivate var isJumping: Bool = false
    fileprivate var isPortrait: Bool = true
    
    /// The index of the front page in `SwipeView` (read only).
    open private(set) var currentIndex: Int = 0
    private var jumpingToIndex: Int?
    
    public init(frame: CGRect, options: SwipeViewOptions? = nil) {
        
        if let options = options {
            self.options = options
        } else {
            self.options = .init()
        }
        
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        self.options = .init()
        
        super.init(coder: aDecoder)
    }
    
    open override func layoutSubviews() {
        
        isLayoutingSubviews = true
        super.layoutSubviews()
        reloadData(isOrientationChange: true)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setup()
    }
    
    /// Reloads all `SwipeView` item views with the dataSource and refreshes the display.
    public func reloadData(options: SwipeViewOptions? = nil, default defaultIndex: Int? = nil, isOrientationChange: Bool = false) {
        
        if let options = options {
            self.options = options
        }
        
        isLayoutingSubviews = isOrientationChange
        
        if !isLayoutingSubviews {
            reset()
            setup(default: defaultIndex ?? currentIndex)
        }
        
        jump(to: defaultIndex ?? currentIndex, animated: false)
        
        isLayoutingSubviews = false
    }
    
    /// Jump to the selected page.
    public func jump(to index: Int, animated: Bool) {
        guard let swipeTabView = swipeTabView, let swipeContentScrollView = swipeContentScrollView else { return }
        if currentIndex != index {
            delegate?.swipeView(self, willChangeIndexFrom: currentIndex, to: index)
        }
        jumpingToIndex = index
        
        // No need to update. It will retrigger the layout update.
        // swipeTabView.jump(to: index)
        swipeContentScrollView.jump(to: index, animated: animated)
    }
    
    /// Notify changing orientaion to `SwipeView` before it.
    public func willChangeOrientation() {
        isLayoutingSubviews = true
    }
    
    fileprivate func update(from fromIndex: Int, to toIndex: Int) {
        
        if !isLayoutingSubviews {
            delegate?.swipeView(self, willChangeIndexFrom: fromIndex, to: toIndex)
        }
        
        swipeTabView?.update(toIndex)
        swipeContentScrollView?.update(toIndex)
        if !isJumping {
            // delay setting currentIndex until end scroll when jumping
            currentIndex = toIndex
        }
        
        if !isJumping && !isLayoutingSubviews {
            delegate?.swipeView(self, didChangeIndexFrom: fromIndex, to: toIndex)
        }
    }
    
    // MARK: - Setup
    private func setup(default defaultIndex: Int = 0) {
        
        delegate?.swipeView(self, viewWillSetupAt: defaultIndex)
        
        backgroundColor = .clear
        
        swipeTabView = SwipeTabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.swipeTabView.height), options: options.swipeTabView)
        swipeTabView?.clipsToBounds = options.swipeTabView.clipsToBounds
        addTabItemGestures()
        
        swipeContentScrollView = SwipeContentScrollView(frame: CGRect(x: 0, y: options.swipeTabView.height, width: frame.width, height: frame.height - options.swipeTabView.height), default: defaultIndex, options: options.swipeContentScrollView)
        swipeContentScrollView?.clipsToBounds = options.swipeContentScrollView.clipsToBounds
        
        swipeTabView?.update(defaultIndex)
        swipeContentScrollView?.update(defaultIndex)
        currentIndex = defaultIndex
        
        delegate?.swipeView(self, viewDidSetupAt: defaultIndex)
    }
    
    private func layout(swipeTabView: SwipeTabView) {
        
        swipeTabView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            swipeTabView.topAnchor.constraint(equalTo: self.topAnchor),
            swipeTabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            swipeTabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            swipeTabView.heightAnchor.constraint(equalToConstant: options.swipeTabView.height)
            ])
    }
    
    private func layout(swipeContentScrollView: SwipeContentScrollView) {
        
        swipeContentScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            swipeContentScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: options.swipeTabView.height),
            swipeContentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            swipeContentScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            swipeContentScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
    
    private func reset() {
        
        if !isLayoutingSubviews {
            currentIndex = 0
        }
        
        if let swipeTabView = swipeTabView, let swipeContentScrollView = swipeContentScrollView {
            swipeTabView.removeFromSuperview()
            swipeContentScrollView.removeFromSuperview()
            swipeTabView.reset()
            swipeContentScrollView.reset()
        }
    }
}

// MARK: - SwipeTabViewDataSource

extension SwipeView: SwipeTabViewDataSource {
    
    public func numberOfItems(in menuView: SwipeTabView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public func swipeTabView(_ swipeTabView: SwipeTabView, titleForItemAt index: Int) -> String? {
        return dataSource?.swipeView(self, titleForPageAt: index)
    }
}

// MARK: - GestureRecognizer

extension SwipeView {
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapItemView(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.cancelsTouchesInView = false
        return gestureRecognizer
    }
    
    fileprivate func addTabItemGestures() {
        swipeTabView?.itemViews.forEach {
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc func tapItemView(_ recognizer: UITapGestureRecognizer) {
        guard let itemView = recognizer.view as? SwipeTabItemView, let swipeTabView = swipeTabView, let index: Int = swipeTabView.itemViews.index(of: itemView), let swipeContentScrollView = swipeContentScrollView else {
            return
        }

        if currentIndex == index {
            return
        }
        
        isJumping = true
        jumpingToIndex = index
        
        swipeContentScrollView.jump(to: index, animated: true)
        moveTabItem(swipeTabView: swipeTabView, index: index)
        
        update(from: currentIndex, to: index)
    }
    
    private func moveTabItem(swipeTabView: SwipeTabView, index: Int) {
        
        switch options.swipeTabView.addition {
        case .underline:
            swipeTabView.animateUnderlineView(index: index, completion: nil)
        case .none:
            swipeTabView.update(index)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SwipeView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isJumping || isLayoutingSubviews { return }
        
        // update currentIndex
        if scrollView.contentOffset.x >= frame.width * CGFloat(currentIndex + 1) {
            update(from: currentIndex, to: currentIndex + 1)
        } else if scrollView.contentOffset.x <= frame.width * CGFloat(currentIndex - 1) {
            update(from: currentIndex, to: currentIndex - 1)
        }
        
        updateSwipeTabViewAddition(by: scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isJumping || isLayoutingSubviews {
            if let toIndex = jumpingToIndex {
                delegate?.swipeView(self, didChangeIndexFrom: currentIndex, to: toIndex)
                currentIndex = toIndex
                jumpingToIndex = nil
            }
            isJumping = false
            isLayoutingSubviews = false
            return
        }
        
        updateSwipeTabViewAddition(by: scrollView)
    }
    
    /// update addition in tab view
    private func updateSwipeTabViewAddition(by scrollView: UIScrollView) {
        moveUnderlineView(scrollView: scrollView)
    }
    
    /// update underbar position
    private func moveUnderlineView(scrollView: UIScrollView) {
        if let swipeTabView = swipeTabView, let swipeContentScrollView = swipeContentScrollView {
            
            let ratio = scrollView.contentOffset.x.truncatingRemainder(dividingBy: swipeContentScrollView.frame.width) / swipeContentScrollView.frame.width
            
            switch scrollView.contentOffset.x {
            case let offset where offset >= frame.width * CGFloat(currentIndex):
                swipeTabView.moveUnderlineView(index: currentIndex, ratio: ratio, direction: .forward)
            case let offset where offset < frame.width * CGFloat(currentIndex):
                swipeTabView.moveUnderlineView(index: currentIndex, ratio: ratio, direction: .reverse)
            default:
                break
            }
        }
    }
}

// MARK: - SwipeContentScrollViewDataSource

extension SwipeView: SwipeContentScrollViewDataSource {
    
    public func numberOfPages(in swipeContentScrollView: SwipeContentScrollView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }
    
    public func swipeContentScrollView(_ swipeContentScrollView: SwipeContentScrollView, viewForPageAt index: Int) -> UIView? {
        return dataSource?.swipeView(self, viewControllerForPageAt: index).view
    }
}
