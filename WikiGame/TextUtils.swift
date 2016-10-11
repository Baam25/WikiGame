//
//  TextUtils.swift
//  WikiGame
//
//  Created by Harish Gonnabhaktula on 10/10/16.
//  Copyright © 2016 Harish Gonnabattula. All rights reserved.
//

import UIKit

class TextUtils {
    
    static var textByLine = [""]
    
    class func partsOfSpeechOf(word:String) -> String {
        
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
    
    class func lines(textView: UITextView) -> Int {
        
        var numberOfLines = 0
        var index = 0
        
        textByLine = [""]
        textByLine.removeFirst()
        
        let layoutManager = textView.layoutManager
        var lineRange : NSRange = NSMakeRange(0, 0)
        for (; index < layoutManager.numberOfGlyphs; numberOfLines += 1) {
            layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
            
            
            let ind = textView.text.startIndex.advancedBy(index)
            
            index = NSMaxRange(lineRange)
            
            textByLine.append(textView.text.substringWithRange(ind..<ind.advancedBy(lineRange.length)))
            
        }
        print("\(numberOfLines)")
        return numberOfLines
    }
    
    class func reset() {
        
        textByLine = [""]
        
    }
    
    
}