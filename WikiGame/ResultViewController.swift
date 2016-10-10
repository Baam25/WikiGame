//
//  ResultViewController.swift
//  WikiGame
//
//  Created by Harish Gonnabhaktula on 09/10/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import UIKit
import SAConfettiView

protocol RestartWikiGame:class {
    func reset()
}

class ResultViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    var score = 0
    weak var delegate: RestartWikiGame?
    override func viewDidLoad() {
        super.viewDidLoad()

        checkScores()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showConfetti() {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        confettiView.type = .Confetti
        self.view.addSubview(confettiView)
        confettiView.startConfetti()
    }
    
    func checkScores() {
        scoreLabel.text = "\(score)/10"
        if score == 10 {
            
            scoreLabel.textColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
            showConfetti()
        }
        else{
            scoreLabel.textColor = UIColor.redColor()
        }
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        
        delegate?.reset()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
   
}
