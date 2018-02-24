//
//  BuyViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 2/7/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class BuyViewController: UIViewController {

    var interactor: Interactor?

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var keyboardView: DefaultNumericKeyboard!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.shadowImage = UIImage()

        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // numericKeyboard.invalidateLayout()
    }
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        print("pressedCloseButton")
                
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func pressedOrderTypesButton(_ sender: Any) {
        print("pressedOrderTypesButton")
        
    }
    
    @IBAction func handleGuesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }

}

extension BuyViewController: NumericKeyboardDelegate {
    
    func numericKeyboard(_ numericKeyboard: NumericKeyboard, itemTapped item: NumericKeyboardItem, atPosition position: Position) {
        print("pressed keyboard: (\(position.row), \(position.column))")
        
        switch (position.row, position.column) {
        default:
            return
        }
    }
    
}
