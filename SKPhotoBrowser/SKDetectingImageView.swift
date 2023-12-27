//
//  SKDetectingImageView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKDetectingImageViewDelegate
@objc protocol SKDetectingImageViewDelegate {
    
    /// handleImageViewSingleTap
    /// - Parameter touchPoint: CGPoint
    func handleImageViewSingleTap(_ touchPoint: CGPoint)
    
    /// handleImageViewDoubleTap
    /// - Parameter touchPoint: CGPoint
    func handleImageViewDoubleTap(_ touchPoint: CGPoint)
}

/// SKDetectingImageView
class SKDetectingImageView: UIImageView {
    
    /// Optional<SKDetectingImageViewDelegate>
    internal weak var delegate: Optional<SKDetectingImageViewDelegate> = .none
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// handleDoubleTap
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc internal func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.handleImageViewDoubleTap(recognizer.location(in: self))
    }
    
    /// handleSingleTap
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc internal func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        delegate?.handleImageViewSingleTap(recognizer.location(in: self))
    }
}

extension SKDetectingImageView {
    
    /// setup
    private func setup() {
        isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
    }
}
