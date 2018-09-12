//
//  ViewController.swift
//  PlayingCards
//
//  Created by Paula Boules on 9/5/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    var isMatched : Bool {
        return faceUpCards.count == 2 &&
            faceUpCards[0].rank == faceUpCards[1].rank &&
            faceUpCards[0].suit == faceUpCards[1].suit
    }
    
    var faceUpCards :[PlayingCardView] {
        return cardViews.filter({$0.isFaceUp && !$0.isHidden})
    }
    @objc func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended :
            let cardView = sender.view as? PlayingCardView
            UIView.transition(
                with: cardView!,
                duration: 0.6,
                options: [.transitionFlipFromLeft],
                animations: {cardView!.isFaceUp = !cardView!.isFaceUp},
                completion: { finished in
                    if self.isMatched {
                        self.faceUpCards.forEach({card in
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.8,
                                delay: 0,
                                options: [],
                                animations: ({
                                    self.faceUpCards.forEach({
                                        $0.transform = CGAffineTransform.identity.scaledBy(x: 5.0, y: 5.0)
                                    })
                                }), completion: ({card in
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.8,
                                        delay: 0,
                                        options: [],
                                        animations: ({
                                            self.faceUpCards.forEach({
                                                $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.01)
                                            })
                                        }), completion: ({card in
                                            self.faceUpCards.forEach({
                                                $0.transform = CGAffineTransform.identity
                                                $0.isHidden = true
                                                $0.alpha = 1
                                            })
                                        })
                                    )
                                })
                            )
                        })
                    }
                        
                    else if self.faceUpCards.count == 2 {
                        self.faceUpCards.forEach({card in
                            UIView.transition(
                                with: card,
                                duration: 0.6,
                                options: [.transitionFlipFromLeft],
                                animations: {card.isFaceUp = !card.isFaceUp})})
                    }
                    
            })
            
            
        default : break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var availPos = [Int]()
        availPos += 0..<8
        
        
        for _ in 0..<4 {
            let cardModel = deck.draw()
            var index = availPos.remove(at: availPos.count.randomIndex)
            cardViews[index].rank = (cardModel?.rank.order)!
            cardViews[index].suit = (cardModel?.suit.rawValue)!
            
            var tap = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
            cardViews[index].addGestureRecognizer(tap  )
            
            index = availPos.remove(at: availPos.count.randomIndex)
            cardViews[index].rank = (cardModel?.rank.order)!
            cardViews[index].suit = (cardModel?.suit.rawValue)!
            
            tap = UITapGestureRecognizer(target: self, action: #selector(self.flipCard(_:)))
            cardViews[index].addGestureRecognizer(tap  )
            
            
        }
    }
    
    
}

extension Int {
    
    var randomIndex :Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
