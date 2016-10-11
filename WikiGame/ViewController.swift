//
//  ViewController.swift
//  WikiGame
//
//  Created by Harish Gonnabhaktula on 03/10/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Kanna
import SCLAlertView
import SAConfettiView

class ViewController: UIViewController, NVActivityIndicatorViewable, answerSelected, RestartWikiGame {

    @IBOutlet weak var wikiText: UITextView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    var generator:AnyGenerator<XMLElement>?
    var tex = ""
    var grammer = [String:String]()
    var confettiView:SAConfettiView!
    var keyWords = [""]
    var prev = ""
    var selectedButton: UIButton?
    var shuffledOptions = [""]
    var originalTex = ""
    var isEvaluationMode = false
    var isSubmitted = false
    var isShowingAnswers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        APIManager.sharedInstance.setUp() //----> Setting up the APIManager
        
        retrieveWiki()   //----> API call to retrieve some random data from Wikipedia
        
        confettiView = SAConfettiView(frame: self.view.bounds)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func retrieveWiki() {
        
        startAnimating(CGSize(width: 40,height: 40), message: "Loading", type: .CubeTransition, color: UIColor.cyanColor(), padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 0)
        
        self.wikiText.hidden = true
        
        //Api call
        APIManager.sharedInstance.httpRequest { (data, response) in
            
            guard let dat = data else{
                self.retrieveWiki()
                return
            }
            
            self.generator = dat.generate()
            
            //Logic to check for minimum lines and fetch more data if less
            if let str = (self.generator?.next()?.text) {
                self.tex = str
                self.originalTex = self.tex.stringByReplacingOccurrencesOfString("\n", withString: " ")

                self.wikiText.text = self.originalTex
                self.wikiText.hidden = false
                self.fill(self.tex, gen: self.generator)
                
                
            }
            else{
                self.retrieveWiki()
            }
            self.stopAnimating()
            
            
            
        }
    }
    

    //MARK:- Function used to check for minimum lines
    func fill(tex:String?,gen:AnyGenerator<XMLElement>?){
        
        
        if TextUtils.lines(wikiText) < 10 {
           
            if gen?.next() != nil {
                let next = gen?.next()?.text!
                if next == "\n" ||  next == ""{
                    
                }
                else{
                    self.tex = self.tex + "\n" + (next!.stringByReplacingOccurrencesOfString("\n", withString: " "))
                    self.originalTex = self.tex
                }
                
            }
            else{
                retrieveWiki()
                return
            }
            self.wikiText.text = self.tex
            fill(self.tex, gen: gen)
        }
        else{
            categorizeWords()
        }
    }
    
    //MARK:- Function to handle rotation of device
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        wikiText.text = originalTex
        tex = originalTex
        fill(tex, gen: self.generator)
        self.wikiText.hidden = false
        
    }
    
    //MARK:- Function to replace random words with blank
    
    func categorizeWords() {
        
        
        
        self.tex = ""
        var begin = wikiText.beginningOfDocument
        var count = 0
        for var line in TextUtils.textByLine {
            
            var words = line.componentsSeparatedByString(" ").filter({ (val) -> Bool in
                return val != ""
            })
            
            
            
            let r = Int(arc4random_uniform(UInt32(words.count)))
            let k = words[r]

            
            var blank = ""
            
            for _ in k.characters {
                blank += "_"
            }
            
            if count < 10 {
                words[r] = blank
                keyWords.append(k)
            }
            
            
            line = words.joinWithSeparator(" ")
            

            
            self.tex += line + "\n"
            self.wikiText.text = self.tex
            
            if count < 10 {
                if count == 0 {
                    prev = line
                }
                else {
                
                    begin = wikiText.positionFromPosition(begin, offset: prev.characters.count+1)!
                    prev = line
                }
            
            
                let pos1 = wikiText.positionFromPosition(begin, offset: line.startIndex.distanceTo(line.rangeOfString("_")!.startIndex))
                let pos2 = wikiText.positionFromPosition(pos1!, offset: k.characters.count)
            
            
                let range = wikiText.textRangeFromPosition(pos1!, toPosition: pos2!)
            
                wikiText.layoutManager.ensureLayoutForTextContainer(wikiText.textContainer)
                
                let rect1 = wikiText.firstRectForRange(range!)
            
                let placeHolderButton = UIButton(frame: rect1)
                
                
                placeHolderButton.titleLabel?.adjustsFontSizeToFitWidth = true
                placeHolderButton.tag = count+1
                placeHolderButton.addTarget(self, action: #selector(ViewController.showOptions(_:)), forControlEvents: .TouchUpInside)
                wikiText.addSubview(placeHolderButton)
            }

            count += 1
            
        }
        
        keyWords = keyWords.filter({ (val) -> Bool in
            return val != ""
        })
        shuffledOptions = keyWords
        self.wikiText.text = self.tex
    }
    
    //MARK:- Function to show the options to select
    func showOptions(sender:UIButton) {
        
        let optionsViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("options") as? OptionsTableViewController
        shuffledOptions.shuffle()
        optionsViewController?.dataSource = shuffledOptions
        selectedButton = sender
        optionsViewController?.delegate = self

        self.navigationController?.pushViewController(optionsViewController!, animated: true)
        
        
    }
    
    //MARK:- Delegate method for answer selection
    func passAnswerValue(answer: String) {
        
        
        shuffledOptions.removeAtIndex(shuffledOptions.indexOf(answer)!)
        
        selectedButton!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        selectedButton?.setTitle(answer, forState: .Normal)
    }
    
    
    //MARK:- Submit the answers
    @IBAction func submitAnswers(sender: AnyObject) {
        let alertController = SCLAlertView()
        
        if isEvaluationMode && isSubmitted{
            for i in 0..<keyWords.count {
                let but = self.view.viewWithTag(i+1) as? UIButton
                if but?.titleLabel?.text != keyWords[i] {
                    but?.setTitle(keyWords[i], forState: .Normal)
                    but?.backgroundColor = UIColor.greenColor()
                    but?.setTitleColor(UIColor.blackColor(), forState: .Normal)
                }
                
            }
            submitButton.title = "Done"
            isEvaluationMode = false
            isShowingAnswers = true
        }
        else if isShowingAnswers {
            alertController.showSuccess("😁", subTitle: "Thank You for taking the test👋").setDismissBlock({
                self.reset()
            })
        }
        else{
            isSubmitted = true
            var score = 0
            for i in 0..<keyWords.count {
                let but = self.view.viewWithTag(i+1) as? UIButton
                if but?.titleLabel?.text == keyWords[i] {
                    score += 1
                }
            
            }
        
            
            if score == 10 {
                self.showConfetti()
        
            
                alertController.addButton("Replay", target: self, selector: #selector(ViewController.reset))
                alertController.addButton("Evaluate", target: self, selector: #selector(ViewController.evaluate))
                alertController.showSuccess("Your Total Score is", subTitle: "\(score)").setDismissBlock({
                        self.confettiView.stopConfetti()
                        self.confettiView.removeFromSuperview()
                    self.submitButton.enabled = false
                })

            }
            else{
            
                alertController.addButton("Replay", target: self, selector: #selector(ViewController.reset))
                alertController.addButton("Evaluate", target: self, selector: #selector(ViewController.evaluate))
                alertController.showWarning("Your Total Score is", subTitle: "\(score)").setDismissBlock({ 
                    self.submitButton.enabled = false
                })
            
            }
        }
        
    }
    
    
    //MARK:- Resetting the game
    func reset() {
        
        retrieveWiki()
        tex = ""
        grammer = [String:String]()
        TextUtils.reset()
        keyWords = [""]
        prev = ""
        shuffledOptions = [""]
        isEvaluationMode = false
        isSubmitted = false
        isShowingAnswers = false
        
        for i in 1...10 {
            wikiText.viewWithTag(i)?.removeFromSuperview()
        }

    }
    
    func evaluate() {
        
        isEvaluationMode = true
        submitButton.title = "Show Answers"
        for i in 0..<keyWords.count {
            let but = self.view.viewWithTag(i+1) as? UIButton
            if but?.titleLabel?.text != keyWords[i] {
                but?.backgroundColor = UIColor.redColor()
            }
            
        }
    }
    
    //MARK:- Confetti View
    func showConfetti() {
        
        confettiView.type = .Confetti
        self.view.addSubview(confettiView)
        confettiView.startConfetti()
    }
    
    
}