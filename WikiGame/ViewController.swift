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

class ViewController: UIViewController, NVActivityIndicatorViewable, answerSelected, RestartWikiGame {

    @IBOutlet weak var wikiText: UITextView!
    var generator:AnyGenerator<XMLElement>?
    var tex = ""
    var grammer = [String:String]()
    
    var keyWords = [""]
    var prev = ""
    var selectedButton: UIButton?
    var shuffledOptions = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        APIManager.sharedInstance.setUp() //----> Setting up the APIManager
        
        retrieveWiki()   //----> API call to retrieve some random data from Wikipedia
        
        
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
                self.wikiText.text = self.tex.stringByReplacingOccurrencesOfString("\n", withString: " ")
                self.fill(self.tex, gen: self.generator)
                self.wikiText.hidden = false
                
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
                }
                
            }
            else{
                retrieveWiki()
                return
            }
            self.wikiText.text = self.tex
            fill(tex, gen: gen)
        }
    }
    
    //MARK:- Function to handle rotation of device
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        fill(self.tex, gen: self.generator)
        self.wikiText.hidden = false
        
    }
    
    //MARK:- Function to replace random words with blank
    
    @IBAction func categorizeWords(sender: AnyObject) {
        
        
        
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
                
                placeHolderButton.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 16.0)
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
        
        let resultController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("result") as? ResultViewController
        resultController?.delegate = self
        var score = 0
        for i in 0..<keyWords.count {
            let but = self.view.viewWithTag(i+1) as? UIButton
            if but?.titleLabel?.text == keyWords[i] {
                score += 1
            }
            
        }
        resultController?.score = score
        self.navigationController?.pushViewController(resultController!, animated: true)
        
        print("Success")
        
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
        
        for i in 1...10 {
            wikiText.viewWithTag(i)?.removeFromSuperview()
        }

    }
    
    
}



