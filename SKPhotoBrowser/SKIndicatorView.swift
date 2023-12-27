//
//  SKIndicatorView.swift
//  SKPhotoBrowser
//
//  Created by suzuki_keishi on 2015/10/09.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKIndicatorView
class SKIndicatorView: UIActivityIndicatorView {
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        style = SKPhotoBrowserOptions.indicatorStyle
        color = SKPhotoBrowserOptions.indicatorColor
    }
}
