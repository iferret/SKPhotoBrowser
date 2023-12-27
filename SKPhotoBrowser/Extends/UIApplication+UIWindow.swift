//
//  UIApplication+UIWindow.swift
//  SKPhotoBrowser
//
//  Created by Josef Dolezal on 25/09/2017.
//  Copyright © 2017 suzuki_keishi. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// UIWindow
    internal var preferredApplicationWindow: Optional<UIWindow> {     
        if #available(iOS 15.0, *) {
            let connectedScenes = connectedScenes.compactMap { $0 as? UIWindowScene }
            if let window = connectedScenes.first(where: { $0.activationState == .foregroundActive })?.windows.first(where: \.isKeyWindow) {
                return window
            } else {
                for connectedScene in connectedScenes {
                    if let window = connectedScene.windows.first(where: \.isKeyWindow) {
                        return window
                    } else {
                        continue
                    }
                }
                return .none
            }
        } else if #available(iOS 13.0, *) {
            return windows.first(where: \.isKeyWindow)
        } else {
            return keyWindow
        }
    }
}
