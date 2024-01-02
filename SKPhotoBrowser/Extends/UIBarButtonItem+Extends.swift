//
//  UIBarButtonItem+Extends.swift
//  SKPhotoBrowser
//
//  Created by iferret on 2024/1/2.
//  Copyright © 2024 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    
    /// flexible
    /// - Returns: UIBarButtonItem
    internal static func flexible() -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            return .flexibleSpace()
        } else {
            return .init(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
        }
    }
    
    /// fixed
    /// - Parameter width: CGFloat
    /// - Returns: UIBarButtonItem
    internal static func fixed(_ width: CGFloat) -> UIBarButtonItem {
        if #available(iOS 14.0, *) {
            return .fixedSpace(width)
        } else {
            let item: UIBarButtonItem = .init(barButtonSystemItem: .fixedSpace, target: .none, action: .none)
            item.width = width
            return item
        }
    }
    
}

extension UIBarButtonItem {
    
    /// customView
    /// - Returns: Optional<T>
    internal func customView<T>() -> Optional<T> where T: UIView {
        return self.customView as? T
    }
}
