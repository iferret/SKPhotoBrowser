//
//  SKDetectingView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKDetectingViewDelegate
@objc protocol SKDetectingViewDelegate {
    
    /// handleSingleTap
    /// - Parameters:
    ///   - view: UIView
    ///   - touch: UITouch
    func handleSingleTap(_ view: UIView, touch: UITouch)
    
    /// handleDoubleTap
    /// - Parameters:
    ///   - view: UIView
    ///   - touch: UITouch
    func handleDoubleTap(_ view: UIView, touch: UITouch)
}

/// SKDetectingView
class SKDetectingView: UIView {
    
    /// SKDetectingViewDelegate
    internal weak var delegate: Optional<SKDetectingViewDelegate> = .none
    
    /// touchesEnded
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: UIEvent
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        defer {
            _ = next
        }
        guard let touch = touches.first else { return }
        switch touch.tapCount {
        case 1 : handleSingleTap(touch)
        case 2 : handleDoubleTap(touch)
        default: break
        }
    }
    
    /// handleSingleTap
    /// - Parameter touch: UITouch
    internal func handleSingleTap(_ touch: UITouch) {
        delegate?.handleSingleTap(self, touch: touch)
    }
    
    /// handleDoubleTap
    /// - Parameter touch: UITouch
    internal func handleDoubleTap(_ touch: UITouch) {
        delegate?.handleDoubleTap(self, touch: touch)
    }
}
