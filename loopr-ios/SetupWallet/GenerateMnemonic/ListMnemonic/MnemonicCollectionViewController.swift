//
//  MnemonicCollectionViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/1/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MnemonicCollectionViewController: UICollectionViewController {
    
    let count: Int = 12
    var mnemonics: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let nib = UINib(nibName: MnemonicCollectionViewCell.getCellIdentifier(), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: MnemonicCollectionViewCell.getCellIdentifier())
        
        self.collectionView?.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if mnemonics.count > 0 {
            return count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicCollectionViewCell.getCellIdentifier(), for: indexPath) as! MnemonicCollectionViewCell
        cell.mnemonicLabel.text = "\(indexPath.row+1). \(mnemonics[indexPath.row])"
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

}
