//
//  MainTabController.swift
//  loopr-ios
//
//  Created by Matthew Cox on 2/3/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {

    var setupViewController: SetupNavigationController? = SetupNavigationController(nibName: nil, bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (!SetupDataManager.shared.hasPresented && setupViewController != nil) {
            SetupDataManager.shared.hasPresented = true

            if (SetupDataManager.shared.hasBeenSetup()) {
                
            } else {
                self.present(setupViewController!, animated: false) {
                    
                }
            }
        } else if (setupViewController != nil) {
            setupViewController = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
