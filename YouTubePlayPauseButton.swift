//
//  YouTubePlayPauseButton.swift
//  YouTubePlayPauseButton
//
//  Created by Ivan Konov on 7/7/18.
//  Copyright © 2018 Ivan Konov. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2018 Ivan Konov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class PausePlayLayer: CAShapeLayer {
    enum Side {
        case left
        case right
    }
    
    enum State {
        case pausedRight
        case pausedLeft
        case playing
    }
    
    var state: PausePlayLayer.State
    var side: PausePlayLayer.Side
    
    init(frame: CGRect, side: PausePlayLayer.Side) {
        self.side = side
        switch side {
        case .left:
            state = .pausedLeft
        case .right:
            state = .pausedRight
        }
        
        super.init()
        
        self.frame = frame
        path = pathForCurrentState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        side = .left
        switch side {
        case .left:
            state = .pausedLeft
        case .right:
            state = .pausedRight
        }
        
        super.init(coder: aDecoder)
        
        path = pathForCurrentState()
    }
    
    private func pathForCurrentState() -> CGPath {
        let width = bounds.size.width
        let height = bounds.size.height
        
        switch state {
        case .pausedRight:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0.333 * height))
            path.addLine(to: CGPoint(x: 0, y: 0.666 * height))
            // We need equal ammount of control points between the different paths to have a proper looking transition(CoreAnimation peculiarities...)
            path.addLine(to: CGPoint(x: width, y: 0.5 * height))
            path.addLine(to: CGPoint(x: width, y: 0.5 * height))
            path.addLine(to: CGPoint(x: 0, y: 0.333 * height))
            path.close()
            
            return path.cgPath
        case .pausedLeft:
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: 0.666 * height))
            path.addLine(to: CGPoint(x: width, y: 0.333 * height))
            path.addLine(to: CGPoint.zero)
            path.close()
            
            return path.cgPath
        case .playing:
            let widthModifier: CGFloat
            switch side {
            case .left:
                widthModifier = 0.47
            case .right:
                widthModifier = 1.0
            }
            
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: widthModifier * width, y: height))
            path.addLine(to: CGPoint(x: widthModifier * width, y: 0))
            path.addLine(to: CGPoint.zero)
            path.close()
            
            return path.cgPath
        }
    }
    
    func toggleState() {
        switch state {
        case .pausedRight:
            state = .playing
        case .pausedLeft:
            state = .playing
        case .playing:
            switch side {
            case .left:
                state = .pausedLeft
            case .right:
                state = .pausedRight
            }
        }
        
        let path = pathForCurrentState()
        CATransaction.setCompletionBlock {
            self.path = path
        }
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = path
        animation.duration = 0.15
        animation.isRemovedOnCompletion = true
        
        add(animation, forKey: "path")
    }
}

class YouTubePlayPauseButton: UIView {
    enum State {
        case paused
        case playing
    }
    typealias ToggleAcion = () -> ()
    
    private let leftWidthProportion: CGFloat = 0.68
    private let rightWidthProportion: CGFloat = 0.32
    
    private var state = YouTubePlayPauseButton.State.playing
    var toggleAction: ToggleAcion?
    
    lazy var leftLayer: PausePlayLayer = {
        let layer = PausePlayLayer(frame: CGRect(x: 0, y: 0, width: leftWidthProportion * bounds.size.width, height: bounds.size.height), side: .left)
        layer.fillColor = tintColor.cgColor
        
        return layer
    }()
    lazy var rightLayer: PausePlayLayer = {
        let layer = PausePlayLayer(frame: CGRect(x: leftWidthProportion * bounds.size.width, y: 0, width: rightWidthProportion * bounds.size.width, height: bounds.size.height), side: .right)
        layer.fillColor = tintColor.cgColor
        
        return layer
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        layer.addSublayer(leftLayer)
        layer.addSublayer(rightLayer)
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(toggleState))
        addGestureRecognizer(touch)
    }
    
    @objc private func toggleState() {
        leftLayer.toggleState()
        rightLayer.toggleState()
        
        toggleAction?()
    }
}
