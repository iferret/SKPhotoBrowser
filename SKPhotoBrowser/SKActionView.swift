//
//  SKOptionalActionView.swift
//  SKPhotoBrowser
//
//  Created by keishi_suzuki on 2017/12/19.
//  Copyright © 2017年 suzuki_keishi. All rights reserved.
//

import UIKit

class SKActionView: UIView {
    
    /// SKPhotoBrowser
    internal weak var browser: Optional<SKPhotoBrowser> = .none
    /// SKCloseButton
    internal var closeButton: SKCloseButton!
    /// SKDeleteButton
    internal var deleteButton: SKDeleteButton!
    
    // Action
    fileprivate var cancelTitle = "Cancel"
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// 构建
    /// - Parameters:
    ///   - frame: CGRect
    ///   - browser: SKPhotoBrowser
    internal convenience init(frame: CGRect, browser: SKPhotoBrowser) {
        self.init(frame: frame)
        self.browser = browser
        configureCloseButton()
        configureDeleteButton()
    }
    
    /// hitTest
    /// - Parameters:
    ///   - point: CGPoint
    ///   - event: UIEvent
    /// - Returns: UIView
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if closeButton.frame.contains(point) || deleteButton.frame.contains(point) {
                return view
            }
            return nil
        }
        return nil
    }
    
    /// updateFrame
    /// - Parameter frame: CGRect
    internal func updateFrame(frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
    }
    
    /// updateCloseButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: CGSize
    internal func updateCloseButton(image: UIImage, size: Optional<CGSize> = .none) {
        configureCloseButton(image: image, size: size)
    }
    
    /// updateDeleteButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: Optional<CGSize>
    internal func updateDeleteButton(image: UIImage, size: Optional<CGSize> = .none) {
        configureDeleteButton(image: image, size: size)
    }
    
    /// animate
    /// - Parameter hidden: Bool
    internal func animate(hidden: Bool) {
        let closeFrame: CGRect = hidden ? closeButton.hideFrame : closeButton.showFrame
        let deleteFrame: CGRect = hidden ? deleteButton.hideFrame : deleteButton.showFrame
        UIView.animate(withDuration: 0.35) {
            let alpha: CGFloat = hidden ? 0.0 : 1.0
            if SKPhotoBrowserOptions.displayCloseButton {
                self.closeButton.alpha = alpha
                self.closeButton.frame = closeFrame
            }
            if SKPhotoBrowserOptions.displayDeleteButton {
                self.deleteButton.alpha = alpha
                self.deleteButton.frame = deleteFrame
            }
        }
    }
    
    /// closeButtonPressed
    /// - Parameter sender: UIButton
    @objc internal func closeButtonPressed(_ sender: UIButton) {
        browser?.determineAndClose()
    }
    
    /// deleteButtonPressed
    /// - Parameter sender: UIButton
    @objc internal func deleteButtonPressed(_ sender: UIButton) {
        guard let browser = self.browser else { return }
        browser.delegate?.browser?(browser, removePhotoAtIndex: browser.currentPageIndex, reload: {[weak self] in
            self?.browser?.deleteImage()
        })
    }
}

extension SKActionView {
    
    /// configureCloseButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: CGSize
    internal func configureCloseButton(image: UIImage? = nil, size: CGSize? = nil) {
        if closeButton == nil {
            closeButton = SKCloseButton(frame: .zero)
            closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
            closeButton.isHidden = !SKPhotoBrowserOptions.displayCloseButton
            addSubview(closeButton)
        }
        if let size = size {
            closeButton.setFrameSize(size)
        }
        if let image = image {
            closeButton.setImage(image, for: .normal)
        }
    }
    
    /// configureDeleteButton
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: CGSize
    internal func configureDeleteButton(image: Optional<UIImage> = .none, size: Optional<CGSize> = .none) {
        if deleteButton == nil {
            deleteButton = SKDeleteButton(frame: .zero)
            deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
            deleteButton.isHidden = !SKPhotoBrowserOptions.displayDeleteButton
            addSubview(deleteButton)
        }
        if let size = size {
            deleteButton.setFrameSize(size)
        }
        if let image = image {
            deleteButton.setImage(image, for: .normal)
        }
    }
}
