//
//  String+capitalizing.swift
//  VoiceBox
//
//  Created by Dmitry on 29.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    //MARK: Sentence processing
    
     func sentenceContainsAll(phrases: String) ->Bool {
        
        let phrasesArray = phrases.split(separator: ",")
        for phrase in phrasesArray{
            if self.lowercased().contains(phrase) == false{
                return false
            }
        }
        return true
    }
    
    func sentenceContainsAny(phrases: String) ->Bool {
        let phrasesArray = phrases.split(separator: ",")
        for phrase in phrasesArray{
            if self.lowercased().contains(phrase) == true{
                return true
            }
        }
        return false
    }
}
