//
//  PlayingCardsDick.swift
//  PlayingCards
//
//  Created by Paula Boules on 9/5/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
    
    private(set) var cards = [PlayingCard]()
    
    init() {
        for suit in PlayingCard.Suit.all{
            for rank in PlayingCard.Rank.all{
                let card =  PlayingCard(suit: suit, rank: rank)
                cards.append(card)
                print(card)
            }
        }
    }
    
    mutating func draw () -> PlayingCard? {
        
        if cards.count>0 {
            return cards.remove(at: cards.count.random)
        } else  {
            return nil
        }
        
    }
    
    
}
extension Int {
    var random : Int {
        if self > 0 {
            return  Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
         return 0
        }
    }
}
