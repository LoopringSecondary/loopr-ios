//
//  NumericKeyboard.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/8/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

public typealias Row = Int
public typealias Column = Int

// MARK: - Position
public typealias Position = (row: Row, column: Column)

// MARK: - NumericKeyboardDataSource
public protocol NumericKeyboardDataSource: class {
    
    /// The number of rows.
    func numberOfRowsInNumericKeyboard(_ numericKeyboard: NumericKeyboard) -> Int
    
    /// The number of columns.
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, numberOfColumnsInRow row: Row) -> Int
    
    /// The item at position.
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemAtPosition position: Position) -> NumericKeyboardItem
}

// MARK: - NumericKeyboardDelegate
public protocol NumericKeyboardDelegate: class {
    
    /// The item was tapped handler.
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position)
    
    /// The size of an item at position.
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, sizeForItemAtPosition position: Position) -> CGSize
    
}

public extension NumericKeyboardDelegate {
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {}
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, sizeForItemAtPosition position: Position) -> CGSize { return CGSize() }
}

// MARK: - NumericKeyboard
open class NumericKeyboard: UIView {
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
        self.addSubview(collectionView)
        collectionView.constrainToEdges()
        return collectionView
        }()
    
    /// Data source for the number pad.
    open weak var dataSource: NumericKeyboardDataSource?
    
    /// Delegate for the number pad.
    open weak var delegate: NumericKeyboardDelegate?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        _ = collectionView
    }
    
    open func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - UICollectionViewDataSource
extension NumericKeyboard: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfRows()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns(section: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let position = self.position(forIndexPath: indexPath)
        guard let item = dataSource?.numericKeyboard(self, itemAtPosition: position) else { return Cell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as! Cell
        cell.item = item
        cell.buttonTapped = { [unowned self] _ in
            self.delegate?.numericKeyboard(self, itemTapped: item, atPosition: position)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NumericKeyboard: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let position = self.position(forIndexPath: indexPath)
        let size = delegate?.numericKeyboard(self, sizeForItemAtPosition: position) ?? CGSize()
        return !size.isZero() ? size : {
            let indexPath = self.indexPath(for: position)
            var size = collectionView.bounds.size
            size.width /= CGFloat(numberOfColumns(section: indexPath.section))
            size.height /= CGFloat(numberOfRows())
            return size
            }()
    }
    
}

// MARK: -
public extension NumericKeyboard {
    
    /// Returns the item at the specified position.
    func item(for position: Position) -> NumericKeyboardItem? {
        let indexPath = self.indexPath(for: position)
        let cell = collectionView.cellForItem(at: indexPath)
        return (cell as? Cell)?.item
    }
    
}

// MARK: -
private extension NumericKeyboard {
    
    /// Returns the index path at the specified position.
    func indexPath(for position: Position) -> IndexPath {
        return IndexPath(item: position.column, section: position.row)
    }
    
    /// Returns the position at the specified index path.
    func position(forIndexPath indexPath: IndexPath) -> Position {
        return Position(row: indexPath.section, column: indexPath.item)
    }
    
    func numberOfRows() -> Int {
        return dataSource?.numberOfRowsInNumericKeyboard(self) ?? 0
    }
    
    func numberOfColumns(section: Int) -> Int {
        return dataSource?.numericKeyboard(self, numberOfColumnsInRow: section) ?? 0
    }
    
}

