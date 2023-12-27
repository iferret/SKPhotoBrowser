//
//  SKMesurement.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

/// SKMesurement
struct SKMesurement {
    
    /// Bool
    static let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    
    /// Bool
    static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    /// CGFloat
    static var statusBarH: CGFloat { UIApplication.shared.statusBarFrame.height }
    
    /// CGFloat
    static var screenHeight: CGFloat {
        return UIApplication.shared.preferredApplicationWindow?.bounds.height ?? UIScreen.main.bounds.height
    }
    
    /// CGFloat
    static var screenWidth: CGFloat {
        return UIApplication.shared.preferredApplicationWindow?.bounds.width ?? UIScreen.main.bounds.width
    }
    
    /// CGFloat
    static var screenScale: CGFloat { UIScreen.main.scale  }
    
    /// CGFloat
    static var screenRatio: CGFloat { screenWidth / screenHeight }
    
    /// Bool
    static var isPhoneX: Bool {
        let iPhoneXHeights: [CGFloat] = [2436, 2688, 1792]
        if isPhone, iPhoneXHeights.contains(UIScreen.main.nativeBounds.height) {
           return true
        }
        return false
    }
}
