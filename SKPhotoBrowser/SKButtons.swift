//
//  SKButtons.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

class SKButton: UIButton {
    
    /// CGRect
    internal var showFrame: CGRect = .zero
    /// CGRect
    internal var hideFrame: CGRect = .zero
    /// UIEdgeInsets
    internal var insets: UIEdgeInsets {
        if SKMesurement.isPhone {
            return UIEdgeInsets(top: 14.0, left: 14.0, bottom: 14.0, right: 14.0)
        } else {
            return UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        }
    }
    
    /// CGSize
    fileprivate let size: CGSize = CGSize(width: 44.0, height: 44.0)
    /// CGFloat
    fileprivate var marginX: CGFloat = 0.0
    /// CGFloat
    fileprivate var marginY: CGFloat = 0.0
    /// CGFloat
    fileprivate var extraMarginY: CGFloat = 20.0 //NOTE: dynamic to static
    
    /// setup
    /// - Parameter imageName: String
    internal func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        setImage(UIImage.bundledImage(named: imageName), for: .normal)
    }
    
    /// setFrameSize
    /// - Parameter size: CGSize
    internal func setFrameSize(_ size: Optional<CGSize> = .none) {
        guard let size = size else { return }
        let newRect = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        frame = newRect
        showFrame = newRect
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
    
    /// updateFrame
    /// - Parameter frameSize: CGSize
    internal func updateFrame(_ frameSize: CGSize) {
        
    }
}

class SKImageButton: SKButton {
    
    /// String
    fileprivate var imageName: String { return "" }
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}

class SKCloseButton: SKImageButton {
    
    /// UIEdgeInsets
    internal override var insets: UIEdgeInsets {
        if SKMesurement.isPhone {
            return UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        } else {
            return UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        }
    }
    
    /// String
    internal override var imageName: String { return "btn_common_close_wh" }
    
    /// CGFloat
    internal override var marginX: CGFloat {
        get {
            if SKPhotoBrowserOptions.swapCloseAndDeleteButtons {
                return SKMesurement.screenWidth - SKButtonOptions.closeButtonPadding.x - self.size.width
            } else {
                return SKButtonOptions.closeButtonPadding.x
            }
        }
        set { super.marginX = newValue }
    }
    
    /// CGFloat
    internal override var marginY: CGFloat {
        get { SKButtonOptions.closeButtonPadding.y + extraMarginY }
        set { super.marginY = newValue }
    }
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}

class SKDeleteButton: SKImageButton {
    
    /// String
    internal override var imageName: String { return "btn_common_delete_wh" }
    /// CGFloat
    internal override var marginX: CGFloat {
        get {
            if SKPhotoBrowserOptions.swapCloseAndDeleteButtons == true {
                return SKButtonOptions.deleteButtonPadding.x
            } else {
                return SKMesurement.screenWidth - SKButtonOptions.deleteButtonPadding.x - self.size.width
            }
        }
        set { super.marginX = newValue }
    }
    /// CGFloat
    internal override var marginY: CGFloat {
        get { SKButtonOptions.deleteButtonPadding.y + extraMarginY }
        set { super.marginY = newValue }
    }
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup(imageName)
        showFrame = CGRect(x: marginX, y: marginY, width: size.width, height: size.height)
        hideFrame = CGRect(x: marginX, y: -marginY, width: size.width, height: size.height)
    }
}
