//
//  SKToolbar.swift
//  SKPhotoBrowser
//
//  Created by keishi_suzuki on 2017/12/20.
//  Copyright © 2017年 suzuki_keishi. All rights reserved.
//

import UIKit

// helpers which often used
private let bundle = Bundle(for: SKPhotoBrowser.self)

/// SKToolbar
class SKToolbar: UIToolbar {
    
    /// UIBarButtonItem
    internal var toolActionButton: Optional<UIBarButtonItem> = .none
    /// SKPhotoBrowser
    fileprivate weak var browser: Optional<SKPhotoBrowser> = .none
    
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
        setupApperance()
        setupToolbar()
    }
    
    /// hitTest
    /// - Parameters:
    ///   - point: CGPoint
    ///   - event: UIEvent
    /// - Returns: UIView
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if SKMesurement.screenWidth - point.x < 50 { // FIXME: not good idea
                return view
            }
        }
        return nil
    }
}

extension SKToolbar {
    
    /// setupApperance
    private func setupApperance() {
        backgroundColor = .clear
        clipsToBounds = true
        isTranslucent = true
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }
    
    /// setupToolbar
    private func setupToolbar() {
        toolActionButton = UIBarButtonItem(barButtonSystemItem: .action, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
        toolActionButton?.tintColor = UIColor.white
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        if SKPhotoBrowserOptions.displayAction, let toolActionButton = toolActionButton {
            items.append(toolActionButton)
        }
        setItems(items, animated: false)
    }
    
    /// setupActionButton
    private func setupActionButton() {
        
    }
}

