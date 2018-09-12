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
    
    @IBOutlet weak var playingCardView: PlayingCardView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
            swipe.direction =  [.right, .left]
            playingCardView.addGestureRecognizer(swipe)
            
            let pinchSelector = #selector(playingCardView.adjustFaceCardScale(byHandlingGestureRecognizerBy:))
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: pinchSelector)
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    @objc func nextCard(){
        print("hello next card")
        if let card = deck.draw() {
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended :
            
            UIView.transition(with: playingCardView, duration: 0.6, options: [.transitionFlipFromLeft], animations: {self.playingCardView.isFaceUp = !self.playingCardView.isFaceUp
                })
            
            
        default : break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

