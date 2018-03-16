//
//  TradePlaceOrderViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/11/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

protocol TradePlaceOrderDelegate: class {
    func closeTradePlaceOrderViewController()
}

class TradePlaceOrderViewController: UIViewController {

    weak var delegate: TradePlaceOrderDelegate?
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBOutlet weak var informationStackView: UIStackView!
    
    @IBAction func pressedPlaceButton(_ sender: UIButton) {
        let vc = TradePlaceReplyViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // FIXME: error drawing layout --kenshin
    override func viewDidLayoutSubviews() {
        for view in informationStackView.subviews {
            let dashedLine = DashedLineView(frame: CGRect(x: informationStackView.frame.origin.x, y: informationStackView.frame.origin.y + view.frame.origin.y + view.frame.size.height, width: informationStackView.frame.size.width, height: 1))
            dashedLine.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
            self.view.addSubview(dashedLine)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        for view in informationStackView.subviews {
//            let dashedLine = DashedLineView(frame: CGRect(x: informationStackView.frame.origin.x, y: informationStackView.frame.origin.y + view.frame.origin.y + view.frame.size.height, width: informationStackView.frame.size.width, height: 1))
//            dashedLine.lineColor = Themes.isNight() ? UIColor.white : UIStyleConfig.defaultTintColor
//            self.view.addSubview(dashedLine)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressedCloseButton(_ sender: Any) {
//        delegate?.closeTradePlaceOrderViewController()
        self.dismiss(animated: true, completion: nil)
    }

}
