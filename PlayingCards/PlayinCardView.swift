//
//  PlayingCard.swift
//  PlayingCards
//
//  Created by Paula Boules on 9/6/18.
//  Copyright © 2018 Paula Boules. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable
    var rank: Int = 3{didSet {setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var suit: String = "♦️" {didSet {setNeedsDisplay(); setNeedsLayout()}}
    @IBInspectable
    var isFaceUp = true{didSet {setNeedsDisplay(); setNeedsLayout()}}
    
//    var imageSizeScale = SizeRatio.faceCardImageSizeToBoundsSize {didSet {
//        setNeedsDisplay()
//        }}
//    @objc func handleSize(recognizer : UIPinchGestureRecognizer){
//        switch recognizer.state {
//        case .changed,.ended:
//            print("hello")
//            imageSizeScale *= recognizer.scale
//            recognizer.scale = 1.0 // reset
//        default:
//            break
//        }
//    }
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet { setNeedsDisplay();print("hello zoom") } }
    
    @ objc func adjustFaceCardScale(byHandlingGestureRecognizerBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    private lazy var upperLeftLabel = createUILabel()
    private lazy var lowerRightLabel = createUILabel()
    
    
    private func createUILabel () -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0 //  as many as you want
        addSubview(label)
        return label
        
    }
    private func configureLayout(label : UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayout(label : upperLeftLabel)
        upperLeftLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy : cornerOffset)
        
        lowerRightLabel.transform =  CGAffineTransform.identity
            .translatedBy(x: lowerRightLabel.frame.size.width,
                          y: lowerRightLabel.frame.size.width)
            .rotated(by: CGFloat.pi)
        configureLayout(label : lowerRightLabel)
        lowerRightLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy : -cornerOffset)
            .offsetBy(dx: -lowerRightLabel.frame.size.width,
                      dy: -lowerRightLabel.frame.size.height)
        
        
    }
    
    private func centeredAttributedString(_ string : String, fontSize: CGFloat)->NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.paragraphStyle : paragraphStyle, .font : font])
    }
    
    private var cornerString :NSAttributedString {
        return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    
    private func drawPips()
    {
        let pipsPerRowForRank = [[0], [1], [1,1], [1,1,1], [2,2], [2,1,2], [2,2,2], [2,1,2,2], [2,2,2,2], [2,2,1,2,2], [2,2,2,2,2]]
        
        func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0)})
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize)
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return probablyOkayPipString
            }
        }
        
        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        path.fill()
        
        if isFaceUp {
            if let imageCardView = UIImage(named: rankString+suit, in : Bundle(for: self.classForCoder), compatibleWith : traitCollection){
                imageCardView.draw(in: bounds.zoom(by: faceCardScale))
            }else {
                drawPips()
            }
        }else {
            if let imageCardView = UIImage(named: "cardback",in : Bundle(for: self.classForCoder), compatibleWith : traitCollection ){
                imageCardView.draw(in: bounds)
            }
        }
    }
}
extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}
extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
extension CGRect {
    func zoom(by zoomFactor: CGFloat) -> CGRect {
        let zoomedWidth = size.width * zoomFactor
        let zoomedHeight = size.height * zoomFactor
        let originX = origin.x + (size.width - zoomedWidth) / 2
        let originY = origin.y + (size.height - zoomedHeight) / 2
        return CGRect(origin: CGPoint(x: originX,y: originY) , size: CGSize(width: zoomedWidth, height: zoomedHeight))
    }
    
    var leftHalf: CGRect {
        let width = size.width / 2
        return CGRect(origin: origin, size: CGSize(width: width, height: size.height))
    }
    
    var rightHalf: CGRect {
        let width = size.width / 2
        return CGRect(origin: CGPoint(x: origin.x + width, y: origin.y), size: CGSize(width: width, height: size.height))
    }
}
