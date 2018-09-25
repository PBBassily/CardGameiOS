//
//  CardBehaviour.swift
//  PlayingCards
//
//  Created by Paula Boules on 9/25/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import Foundation
import UIKit

class CardBehavior: UIDynamicBehavior {
    
    struct Constants {
        static var flipCardAnimationDuration: TimeInterval = 0.6
        static var matchCardAnimationDuration: TimeInterval = 0.6
        static var matchCardAnimationScaleUp: CGFloat = 3.0
        static var matchCardAnimationScaleDown: CGFloat = 0.1
        static var behaviorResistance: CGFloat = 0
        static var behaviorElasticity: CGFloat = 1.0
        static var behaviorPushMagnitudeMinimum: CGFloat = 0.5
        static var behaviorPushMagnitudeRandomFactor: CGFloat = 1.0
        static var cardsPerMainViewWidth: CGFloat = 5
    }
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = Constants.behaviorElasticity
        behavior.resistance = Constants.behaviorResistance
        return behavior
    }()
    
    
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            push.angle = (CGFloat.pi/2).arc4random
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -1 * push.angle
            case let (x, y) where x > center.x:
                push.angle = y < center.y ? CGFloat.pi-push.angle: CGFloat.pi+push.angle
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
        }
        push.magnitude = CGFloat(Constants.behaviorPushMagnitudeMinimum) + CGFloat(Constants.behaviorPushMagnitudeRandomFactor).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
}


extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
