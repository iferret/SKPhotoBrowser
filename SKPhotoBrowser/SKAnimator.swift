//
//  SKAnimator.swift
//  SKPhotoBrowser
//
//  Created by keishi suzuki on 2016/08/09.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKPhotoBrowserAnimatorDelegate
@objc public protocol SKPhotoBrowserAnimatorDelegate {
    
    /// willPresent
    /// - Parameter browser: SKPhotoBrowser
    func willPresent(_ browser: SKPhotoBrowser)
    
    /// willDismiss
    /// - Parameter browser: SKPhotoBrowser
    func willDismiss(_ browser: SKPhotoBrowser)
}

/// SKAnimator
class SKAnimator: NSObject, SKPhotoBrowserAnimatorDelegate {
    
    /// UIWindow
    fileprivate let window: Optional<UIWindow> = UIApplication.shared.preferredApplicationWindow
    fileprivate var resizableImageView: Optional<UIImageView> = .none
    fileprivate var finalImageViewFrame: CGRect = .zero
    /// UIView
    internal lazy var backgroundView: UIView = {
        guard let window = UIApplication.shared.preferredApplicationWindow else { fatalError() }
        let backgroundView = UIView(frame: window.frame)
        backgroundView.backgroundColor = SKPhotoBrowserOptions.backgroundColor
        backgroundView.alpha = 0.0
        return backgroundView
    }()
    /// UIImage
    internal var senderOriginImage: UIImage!
    /// CGRect
    internal var senderViewOriginalFrame: CGRect = .zero
    /// UIView
    internal var senderViewForAnimation: Optional<UIView> = .none
    /// TimeInterval
    fileprivate var animationDuration: TimeInterval {
        if SKPhotoBrowserOptions.bounceAnimation { return 0.5 }
        return 0.35
    }
    /// CGFloat
    fileprivate var animationDamping: CGFloat {
        if SKPhotoBrowserOptions.bounceAnimation { return 0.8 }
        return 1.0
    }
    
    /// 构建
    internal override init() {
        super.init()
        window?.addSubview(backgroundView)
    }
    
    /// deinit
    deinit {
        backgroundView.removeFromSuperview()
    }
    
    /// willPresent
    /// - Parameter browser: SKPhotoBrowser
    internal func willPresent(_ browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.browser?(browser, viewForPhotoAtIndex: browser.currentIndex) ?? senderViewForAnimation else {
            presentAnimation(browser)
            return
        }
        
        let photo = browser.photoAtIndex(browser.currentIndex)
        let imageFromView = (senderOriginImage ?? browser.getImageFromView(sender)).rotateImageByOrientation()
        let imageRatio = imageFromView.size.width / imageFromView.size.height
        
        senderViewOriginalFrame = calcOriginFrame(sender)
        finalImageViewFrame = calcFinalFrame(imageRatio)
        resizableImageView = UIImageView(image: imageFromView)
        
        if let resizableImageView = resizableImageView {
            resizableImageView.frame = senderViewOriginalFrame
            resizableImageView.clipsToBounds = true
            resizableImageView.contentMode = photo.contentMode
            if sender.layer.cornerRadius != 0 {
                let duration = (animationDuration * Double(animationDamping))
                resizableImageView.layer.masksToBounds = true
                resizableImageView.addCornerRadiusAnimation(sender.layer.cornerRadius, to: 0, duration: duration)
            }
            window?.addSubview(resizableImageView)
        }
        
        presentAnimation(browser)
    }
    
    /// willDismiss
    /// - Parameter browser: SKPhotoBrowser
    internal func willDismiss(_ browser: SKPhotoBrowser) {
        guard let sender = browser.delegate?.browser?(browser, viewForPhotoAtIndex: browser.currentIndex),
              let image = browser.photoAtIndex(browser.currentIndex).underlyingImage,
              let scrollView = browser.pageDisplayedAtIndex(browser.currentIndex) else {
            senderViewForAnimation?.isHidden = false
            browser.dismissPhotoBrowser(animated: false) {
                self.resizableImageView?.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
            return
        }
        
        senderViewForAnimation = sender
        browser.view.isHidden = true
        backgroundView.isHidden = false
        backgroundView.alpha = 1.0
        backgroundView.backgroundColor = .clear
        senderViewOriginalFrame = calcOriginFrame(sender)
        
        if let resizableImageView = resizableImageView {
            let photo = browser.photoAtIndex(browser.currentIndex)
            let contentOffset = scrollView.contentOffset
            let scrollFrame = scrollView.imageView?.frame ?? .zero
            let offsetY = scrollView.center.y - (scrollView.bounds.height/2)
            let frame = CGRect(
                x: scrollFrame.origin.x - contentOffset.x,
                y: scrollFrame.origin.y + contentOffset.y + offsetY - scrollView.contentOffset.y,
                width: scrollFrame.width,
                height: scrollFrame.height)
            
            resizableImageView.image = image.rotateImageByOrientation()
            resizableImageView.frame = frame
            resizableImageView.alpha = 1.0
            resizableImageView.clipsToBounds = true
            resizableImageView.contentMode = photo.contentMode
            if let view = senderViewForAnimation, view.layer.cornerRadius != 0 {
                let duration = (animationDuration * Double(animationDamping))
                resizableImageView.layer.masksToBounds = true
                resizableImageView.addCornerRadiusAnimation(0, to: view.layer.cornerRadius, duration: duration)
            }
        }
        dismissAnimation(browser)
    }
}

extension SKAnimator {
    
    /// calcOriginFrame
    /// - Parameter sender: UIView
    /// - Returns: CGRect
    private func calcOriginFrame(_ sender: UIView) -> CGRect {
        if let senderViewOriginalFrameTemp = sender.superview?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else if let senderViewOriginalFrameTemp = sender.layer.superlayer?.convert(sender.frame, to: nil) {
            return senderViewOriginalFrameTemp
        } else {
            return .zero
        }
    }
    
    /// calcFinalFrame
    /// - Parameter imageRatio: CGFloat
    /// - Returns: CGFloat
    private func calcFinalFrame(_ imageRatio: CGFloat) -> CGRect {
        guard !imageRatio.isNaN else { return .zero }
        if SKMesurement.screenRatio < imageRatio {
            let width = SKMesurement.screenWidth
            let height = width / imageRatio
            let yOffset = (SKMesurement.screenHeight - height) / 2
            return CGRect(x: 0, y: yOffset, width: width, height: height)
            
        } else if SKPhotoBrowserOptions.longPhotoWidthMatchScreen && imageRatio <= 1.0 {
            let height = SKMesurement.screenWidth / imageRatio
            return CGRect(x: 0.0, y: 0, width: SKMesurement.screenWidth, height: height)
            
        } else {
            let height = SKMesurement.screenHeight
            let width = height * imageRatio
            let xOffset = (SKMesurement.screenWidth - width) / 2
            return CGRect(x: xOffset, y: 0, width: width, height: height)
        }
    }
}

extension SKAnimator {
    
    /// presentAnimation
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - completion: Optional<() -> Void>
    private func presentAnimation(_ browser: SKPhotoBrowser, completion: Optional<() -> Void> = .none) {
        let finalFrame = self.finalImageViewFrame
        browser.view.isHidden = true
        browser.view.alpha = 0.0
        
        if #available(iOS 11.0, *) {
            backgroundView.accessibilityIgnoresInvertColors = true
            self.resizableImageView?.accessibilityIgnoresInvertColors = true
        }
        // animate
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0, options: [], animations: {
            browser.showButtons()
            self.backgroundView.alpha = 1.0
            self.resizableImageView?.frame = finalFrame
        }, completion: { (_) -> Void in
            browser.view.alpha = 1.0
            browser.view.isHidden = false
            self.backgroundView.isHidden = true
            self.resizableImageView?.alpha = 0.0
        })
    }
    
    /// dismissAnimation
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - completion: Optional<() -> Void>
    private func dismissAnimation(_ browser: SKPhotoBrowser, completion: Optional<() -> Void> = .none) {
        let finalFrame = self.senderViewOriginalFrame
        // animate
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: animationDamping, initialSpringVelocity: 0, options: [], animations: {
            self.backgroundView.alpha = 0.0
            self.resizableImageView?.layer.frame = finalFrame
        }, completion: { (_) -> Void in
            browser.dismissPhotoBrowser(animated: true) {
                self.resizableImageView?.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        })
    }
}

