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
    var confettiView:SAConfettiView!
    weak var delegate: RestartWikiGame?
    var settingsButton : UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        confettiView = SAConfettiView(frame: self.view.bounds)
        checkScores()
        settingsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(ResultViewController.showOptions))
        self.navigationItem.rightBarButtonItem = settingsButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showConfetti() {
        
        confettiView.type = .Confetti
        self.view.addSubview(confettiView)
        confettiView.startConfetti()
    }
    
    func checkScores() {
        scoreLabel.text = "\(score)/10"
        if score == 10 {
            
            scoreLabel.textColor = UIColor(red: 0, green: 128/255, blue: 0, alpha: 1)
            UIView.animateWithDuration(3.0, animations: {
                    self.showConfetti()
                }, completion: { (completed) in
                    self.confettiView.stopConfetti()
            })
            
        }
        else{
            scoreLabel.textColor = UIColor.redColor()
        }
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        
        delegate?.reset()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showOptions() {
        
        let options = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let showComparision = UIAlertAction(title: "Solutions", style: UIAlertActionStyle.Default) { (action) in
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        options.addAction(showComparision)
        options.addAction(cancel)
        
        self.presentViewController(options, animated: true, completion: nil)
    }
    
   
}
