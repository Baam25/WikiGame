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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       startAnimating(CGSize(width: 40,height: 40), message: "Loading", type: .CubeTransition, color: UIColor.cyanColor(), padding: 0, displayTimeThreshold: 0, minimumDisplayTime: 0)
        
        APIManager.sharedInstance.setUp()
        
        retrieveWiki()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func retrieveWiki() {
        self.wikiText.hidden = true
        APIManager.sharedInstance.httpRequest { (data, response) in
            
            guard let dat = data else{
                self.retrieveWiki()
                return
            }
            self.generator = dat.generate()
            self.tex = (self.generator?.next()?.text) ?? ""
            self.wikiText.text = self.tex.stringByReplacingOccurrencesOfString("\n", withString: " ")
            self.fill(self.tex, gen: self.generator)
            self.wikiText.hidden = false
            self.stopAnimating()
            
        }
    }
    
    func lines() -> Int {
        var lineCount = 0;
        let textSize = CGSizeMake(wikiText.frame.size.width, CGFloat(Float.infinity));
        let rHeight = lroundf(Float(wikiText.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(wikiText.font?.lineHeight ?? 0))
        lineCount = rHeight/charSize
        print("No of lines \(lineCount)")
        return lineCount
    }
    
    func fill(tex:String?,gen:AnyGenerator<XMLElement>?){
        
        if self.lines() < 10 {
            if gen?.next() != nil {
                
                self.tex = self.tex + "\n" + (gen!.next()!.text!.stringByReplacingOccurrencesOfString("\n", withString: " "))
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
        textByLine.removeFirst()
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
            
            keyWords.append(k)
            
            var blank = ""
            
            for _ in k.characters {
                blank += "_"
            }
            
            if c < 10 {
                words[r] = blank
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
            
            let v = UIButton(frame: rect1)//UIView(frame: rect1)
            v.titleLabel?.font.fontWithSize(18)
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

        self.wikiText.text = self.tex
    }
    
    
    func showOptions(sender:UIButton) {
        
        let optionsViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("options") as? OptionsTableViewController
        
        optionsViewController?.dataSource = keyWords
        selectedButton = sender
        optionsViewController?.delegate = self

        self.navigationController?.pushViewController(optionsViewController!, animated: true)
        
        
    }
    
    func passAnswerValue(answer: String) {
        
        selectedButton!.setTitleColor(UIColor.blackColor(), forState: .Normal)
        selectedButton?.setTitle(answer, forState: .Normal)
    }
    
    
    @IBAction func submitAnswers(sender: AnyObject) {
        
        let resultController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("result") as? ResultViewController
        
        for i in 1...10 {
            let but = self.view.viewWithTag(i) as? UIButton
            if but?.titleLabel?.text == keyWords[i-1] {
                continue
            }
            else{
                resultController?.score = i-1
                self.navigationController?.pushViewController(resultController!, animated: true)
                print("failed")
                return
            }
            
        }
        resultController?.score = 10
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
