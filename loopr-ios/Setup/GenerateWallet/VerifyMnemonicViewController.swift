//
//  VerifyMnemonicViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 3/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit

class VerifyMnemonicViewController: UIViewController {

    var questionLabel = UILabel()
    
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    var button4 = UIButton()
    var buttonStackView = UIStackView()

    var currentIndex: Int = -1
    
    let progressView = UIProgressView(progressViewStyle: .bar)
    
    var enterWalletButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Verification", comment: "")
        setBackButton()

        view.theme_backgroundColor = GlobalPicker.backgroundColor

        // Setup UI
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height

        let originY: CGFloat = 30
        let padding: CGFloat = 15
        
        progressView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 1)
        progressView.tintColor = UIColor.black
        view.addSubview(progressView)
        
        questionLabel.frame = CGRect(x: padding, y: originY, width: screenWidth - padding * 2, height: 90)
        questionLabel.font = UIFont.init(name: FontConfigManager.shared.getMedium(), size: 24)
        questionLabel.numberOfLines = 0
        view.addSubview(questionLabel)
        
        buttonStackView.frame = CGRect(center: CGPoint(x: screenWidth*0.5, y: screenHeight*0.45), size: CGSize(width: 165, height: 47*4+20*3))
        buttonStackView.axis = UILayoutConstraintAxis.vertical
        buttonStackView.distribution = UIStackViewDistribution.fillEqually
        buttonStackView.spacing = 20

        buttonStackView.alignment = UIStackViewAlignment.fill
        buttonStackView.backgroundColor = UIColor.red
        
        view.addSubview(buttonStackView)

        button1.addTarget(self, action: #selector(pressedButton1), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button1)

        button2.addTarget(self, action: #selector(pressedButton2), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button2)

        button3.addTarget(self, action: #selector(pressedButton3), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button3)

        button4.addTarget(self, action: #selector(pressedButton4), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button4)
        
        loadNextQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadNextQuestion() {
        if currentIndex < 0 {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        
        if currentIndex == 24 {
            // TODO: verify the inputs
            
            // Store the new wallet to the local storage.
            _ = GenerateWalletDataManager.shared.complete()
            
            // Show enter wallet button
            let width = view.bounds.width
            let height = view.bounds.height
            
            enterWalletButton.frame = CGRect(x: 15, y: height-47-15, width: width-2*15, height: 47)
            enterWalletButton.setupRoundBlack()
            enterWalletButton.setTitle(NSLocalizedString("Enter Wallet", comment: ""), for: .normal)
            enterWalletButton.addTarget(self, action: #selector(dismissGenerateWallet), for: .touchUpInside)
            view.addSubview(enterWalletButton)
        } else {
            let mnemonicQuestion = GenerateWalletDataManager.shared.getQuestion(index: currentIndex)
            
            progressView.setProgress(Float(currentIndex+1)/24.0, animated: true)
            
            questionLabel.text = mnemonicQuestion.question
            
            button1.setTitle(mnemonicQuestion.options[0], for: .normal)
            button2.setTitle(mnemonicQuestion.options[1], for: .normal)
            button3.setTitle(mnemonicQuestion.options[2], for: .normal)
            button4.setTitle(mnemonicQuestion.options[3], for: .normal)
            
            button1.setupRoundWhite()
            button2.setupRoundWhite()
            button3.setupRoundWhite()
            button4.setupRoundWhite()
        }
    }
    
    @objc func pressedButton1(_ sender: Any) {
        print("pressedButton1")
        button1.setupRoundBlack()
        button2.setupRoundWhite()
        button3.setupRoundWhite()
        button4.setupRoundWhite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.loadNextQuestion()
        })
    }

    @objc func pressedButton2(_ sender: Any) {
        print("pressedButton2")
        button1.setupRoundWhite()
        button2.setupRoundBlack()
        button3.setupRoundWhite()
        button4.setupRoundWhite()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.loadNextQuestion()
        })
    }
    
    @objc func pressedButton3(_ sender: Any) {
        print("pressedButton3")
        button1.setupRoundWhite()
        button2.setupRoundWhite()
        button3.setupRoundBlack()
        button4.setupRoundWhite()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.loadNextQuestion()
        })
    }
    
    @objc func pressedButton4(_ sender: Any) {
        print("pressedButton4")
        button1.setupRoundWhite()
        button2.setupRoundWhite()
        button3.setupRoundWhite()
        button4.setupRoundBlack()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.loadNextQuestion()
        })
    }

    @IBAction func pressedCompleteButton(_ sender: Any) {
        print("pressedCompleteButton")
        
        // TODO: Since we haven't implemented the UI to enter mnemonic, this should always return false.
        if GenerateWalletDataManager.shared.verify() {
            
        } else {
            // Store the new wallet to the local storage.
            let appWallet = GenerateWalletDataManager.shared.complete()
            
            let alertController = UIAlertController(title: "Create \(appWallet.name) successfully",
                                                    message: "We are working on the features in the verification page.",
                                                    preferredStyle: .alert)

            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismissGenerateWallet()
            })
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @objc func dismissGenerateWallet() {
        if SetupDataManager.shared.hasPresented {
            self.dismiss(animated: true, completion: {
                
            })
        } else {
            SetupDataManager.shared.hasPresented = true
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        }
    }

}
