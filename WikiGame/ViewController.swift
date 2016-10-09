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


class ViewController: UIViewController, NVActivityIndicatorViewable, answerSelected {

    @IBOutlet weak var wikiText: UITextView!
    var generator:AnyGenerator<XMLElement>?
    var tex = ""
    var grammer = [String:String]()
    var textByLine = [""]
    var keyWords = [""]
    var prev = ""
    var selectedButton: UIButton?
    var shuffledOptions = [""]
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        APIManager.sharedInstance.setUp()
        
        retrieveWiki()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func retrieveWiki() {
        
        startAnimating(CGSize(width: 40,height: 40), message: "Loading", type: .CubeTransition, color: UIColor.cyanColor(), padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 0)
        self.wikiText.hidden = true
        APIManager.sharedInstance.httpRequest { (data, response) in
            
            guard let dat = data else{
                self.retrieveWiki()
                return
            }
            self.generator = dat.generate()
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
            //self.tex = (self.generator?.next()?.text)
            
            
        }
    }
    
    func lines() -> Int {
        
//        var lineCount = 0;
//        let textSize = CGSizeMake(wikiText.frame.size.width, CGFloat(Float.infinity));
//        let rHeight = lroundf(Float(wikiText.sizeThatFits(textSize).height))
//        let charSize = lroundf(Float(wikiText.font?.lineHeight ?? 1.0))
//        lineCount = rHeight/charSize
//        print("No of lines \(lineCount)")
//        return lineCount
        textByLine = [""]
        textByLine.removeFirst()
        let layoutManager = wikiText.layoutManager
        var numberOfLines = 0
        var index = 0
        var lineRange : NSRange = NSMakeRange(0, 0)
        for (; index < layoutManager.numberOfGlyphs; numberOfLines += 1) {
            layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
            
            
            let ind = wikiText.text.startIndex.advancedBy(index)
            
            index = NSMaxRange(lineRange)
            
            textByLine.append(wikiText.text.substringWithRange(ind..<ind.advancedBy(lineRange.length)))
            
        }
        print("\(numberOfLines)")
        return numberOfLines
    }
    
    func fill(tex:String?,gen:AnyGenerator<XMLElement>?){
        
        
        if self.lines() < 10 {
           
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
    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        
//        fill(self.tex, gen: self.generator)
//        self.wikiText.hidden = false
//        
//    }
//    
    
    
    @IBAction func categorizeWords(sender: AnyObject) {
        
        
        
        self.tex = ""
        var begin = wikiText.beginningOfDocument
        var c = 0
        for var line in textByLine {
            
            var words = line.componentsSeparatedByString(" ").filter({ (val) -> Bool in
                return val != ""
            })
            
            
            
            let r = Int(arc4random_uniform(UInt32(words.count)))
            let k = words[r]
            
//            if ["Adjective","Adverb","Verb","Preposition"].contains(partsOfSpeechOf(k)) {
//                keyWords.append(k)
//            }
//            else{
//                c += 1
//                continue
//            }
            
            
            
            var blank = ""
            
            for _ in k.characters {
                blank += "_"
            }
            
            if c < 10 {
                words[r] = blank
                keyWords.append(k)
            }
            
            
            line = words.joinWithSeparator(" ")
            

            
            self.tex += line + "\n"
            self.wikiText.text = self.tex
            
            if c < 10 {
            if c == 0 {
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
            
            let v = UIButton(frame: rect1)
                
            v.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 18.0)
            v.titleLabel?.adjustsFontSizeToFitWidth = true
            v.tag = c+1
            v.addTarget(self, action: #selector(ViewController.showOptions(_:)), forControlEvents: .TouchUpInside)
            wikiText.addSubview(v)
            }

            c += 1
            
        }
        
        keyWords = keyWords.filter({ (val) -> Bool in
            return val != ""
        })
        shuffledOptions = keyWords
        self.wikiText.text = self.tex
    }
    
    
    func showOptions(sender:UIButton) {
        
        let optionsViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("options") as? OptionsTableViewController
        shuffledOptions.shuffle()
        optionsViewController?.dataSource = shuffledOptions
        selectedButton = sender
        optionsViewController?.delegate = self

        self.navigationController?.pushViewController(optionsViewController!, animated: true)
        
        
    }
    
    func passAnswerValue(answer: String) {
        
        
        shuffledOptions.removeAtIndex(shuffledOptions.indexOf(answer)!)
        
        selectedButton!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        selectedButton?.setTitle(answer, forState: .Normal)
    }
    
    
    @IBAction func submitAnswers(sender: AnyObject) {
        
        let resultController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("result") as? ResultViewController
        var score = 0
        for i in 1...10 {
            let but = self.view.viewWithTag(i) as? UIButton
            if but?.titleLabel?.text == keyWords[i-1] {
                score += 1
            }
            
        }
        resultController?.score = score
        self.navigationController?.pushViewController(resultController!, animated: true)
        
        print("Success")
        
    }
    
    func partsOfSpeechOf(word:String) -> String {
        
        let options: NSLinguisticTaggerOptions = [.OmitWhitespace, .OmitPunctuation, .JoinNames]
        let schemes = NSLinguisticTagger.availableTagSchemesForLanguage("en")
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        var Tag = ""
        tagger.string = word
        
        tagger.enumerateTagsInRange(NSMakeRange(0, (word as NSString).length), scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options)
        { (tag, tokenRange, _, _) in
            
            let token = (word as NSString).substringWithRange(tokenRange)
            Tag = tag
            print("\(token): \(tag)")
        }
        
        return Tag
    }
    
}


extension Array
{
    /** Randomizes the order of an array's elements. */
    mutating func shuffle()
    {
        for _ in 0..<10
        {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}
