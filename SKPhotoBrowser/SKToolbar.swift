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
    /// Optional<UIBarButtonItem>
    internal var toolDownloadButton: Optional<UIBarButtonItem> = .none
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
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        if SKPhotoBrowserOptions.displayDownload == true {
            let img: UIImage = .bundledImage(named: "btn_common_download_wh").redrawWith(.init(width: 20.0, height: 20.0)).withRenderingMode(.alwaysTemplate)
            toolDownloadButton = .init(image: img, style: .plain, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
            toolDownloadButton!.tintColor = UIColor.white
            // items.append(toolActionButton!)
        }
        if SKPhotoBrowserOptions.displayAction == true {
            let img: UIImage = .bundledImage(named: "btn_common_share_wh").redrawWith(.init(width: 20.0, height: 20.0)).withRenderingMode(.alwaysTemplate)
            toolActionButton = .init(image: img, style: .plain, target: browser, action: #selector(SKPhotoBrowser.actionButtonPressed))
            toolActionButton!.tintColor = UIColor.white
            // items.append(toolActionButton!)
        }
        setItems(items, animated: false)
    }
    
    /// setupActionButton
    private func setupActionButton() {
        
    }
    
    /// hideActionButton
    /// - Parameter hidden: Bool
    internal func hideActionButton(_ hidden: Bool) {
        guard let item = toolActionButton else { return }
        switch (items, hidden) {
        case (.some(let items), true) where items.contains(item) == true:
            var items = items
            items.removeAll(where: { $0 == item })
            self.setItems(items, animated: false)
        case (.some(let items), false) where items.contains(item) == false:
            var items = items
            items.append(item)
            self.setItems(items, animated: false)
        default: break
        }
    }
    
    /// hideDownloadButton
    /// - Parameter hidden: Bool
    internal func hideDownloadButton(_ hidden: Bool) {
        guard let item = toolDownloadButton else { return }
        switch (items, hidden) {
        case (.some(let items), true) where items.contains(item) == true:
            var items = items
            items.removeAll(where: { $0 == item })
            self.setItems(items, animated: false)
        case (.some(let items), false) where items.contains(item) == false:
            var items = items
            items.append(item)
            self.setItems(items, animated: false)
        default: break
        }
    }
}

