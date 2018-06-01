//
//  MnemonicBackupModeCollectionViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 5/30/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol MnemonicBackupModeCollectionViewControllerDelegate: class {
    func collectionViewDidSelectItemAt(indexPath: IndexPath)
}

class MnemonicBackupModeCollectionViewController: UICollectionViewController {
    
    weak var delegate: MnemonicBackupModeCollectionViewControllerDelegate?
    
    var isBackupMode: Bool = false
    let count: Int = 12
    var index = 0
    var mnemonics: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let nib = UINib(nibName: MnemonicBackupModeCollectionViewCell.getCellIdentifier(), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: MnemonicBackupModeCollectionViewCell.getCellIdentifier())
        
        self.collectionView?.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GenerateWalletDataManager.shared.clearUserInputMnemonic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MnemonicBackupModeCollectionViewCell.getCellIdentifier(), for: indexPath) as! MnemonicBackupModeCollectionViewCell
        
        cell.mnemonicLabel.text = mnemonics[indexPath.row]

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !GenerateWalletDataManager.shared.getUserInputMnemonics().contains(mnemonics[indexPath.row]) {
            if let cell = collectionView.cellForItem(at: indexPath) as? MnemonicBackupModeCollectionViewCell {
                cell.mnemonicLabel.textColor = UIColor.white
                cell.mnemonicLabel.layer.backgroundColor  = UIColor.black.cgColor
                cell.mnemonicLabel.layer.cornerRadius = cell.mnemonicLabel.frame.height*0.5
            }
            delegate?.collectionViewDidSelectItemAt(indexPath: indexPath)
        }
    }

}
