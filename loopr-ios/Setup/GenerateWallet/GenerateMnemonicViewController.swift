//
//  GenerateMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class GenerateMnemonicViewController: UIViewController {

    var congratulationIconView = UIImageView()
    var congratulationsLabel: UILabel = UILabel()
    @IBOutlet weak var backupNowButton: UIButton!
    @IBOutlet weak var detailTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        backupNowButton.backgroundColor = UIColor.black
        backupNowButton.layer.cornerRadius = 23
        backupNowButton.titleLabel?.font = UIFont(name: FontConfigManager.shared.getBold(), size: 17.0)
        
        // Setup UI in the scroll view
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        // let screenHeight = screensize.height
        
        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        congratulationIconView.frame = CGRect(x: 15, y: originY+1, width: 22, height: 22)
        congratulationIconView.image = UIImage(named: "CongratulationIcon")
        view.addSubview(congratulationIconView)

        congratulationsLabel.frame = CGRect(x: 45, y: originY, width: screenWidth - padding * 2, height: 30)
        congratulationsLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 27)
        congratulationsLabel.text = "Congratualations!"
        view.addSubview(congratulationsLabel)

        detailTextView.font = FontConfigManager.shared.getLabelFont()

        view.theme_backgroundColor = GlobalPicker.backgroundColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pressedBackupNowButton(_ sender: Any) {
        print("pressedBackupNowButton")
        let viewController = BackupMnemonicViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

}
