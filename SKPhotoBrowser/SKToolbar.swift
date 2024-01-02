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

/// SKToolbarDelegate
protocol SKToolbarDelegate: AnyObject {
    
    /// shareActionHandler
    /// - Parameters:
    ///   - toolbar: SKToolbar
    ///   - sender: UIBarButtonItem
    func toolbar(_ toolbar: SKToolbar, shareActionHandler sender: UIBarButtonItem)
    
    /// downloadActionHandler
    /// - Parameters:
    ///   - toolbar: SKToolbar
    ///   - sender: UIBarButtonItem
    func toolbar(_ toolbar: SKToolbar, downloadActionHandler sender: UIBarButtonItem)
    
}

/// SKToolbar
class SKToolbar: UIView {
    /// SKPhotoBrowser.ActionKind
    typealias ActionKind = SKPhotoBrowser.ActionKind
    
    // MARK: 公开属性
    
    /// Optional<ActionKind>
    internal var actionKind: Optional<ActionKind> = .none {
        didSet { setupToolbar(with: actionKind) }
    }
    /// Optional<UIBarButtonItem>
    internal var leftBarButtonItem: Optional<UIBarButtonItem> { toolbar.items?.first }
    /// Optional<UIBarButtonItem>
    internal var rightBarButtonItem: Optional<UIBarButtonItem> { toolbar.items?.last }
    /// Optional<UIActivityIndicatorView>
    internal var loadingView: Optional<UIActivityIndicatorView> { toolbar.items?.first(where: { $0.customView is UIActivityIndicatorView })?.customView() }
    /// Optional<[UIBarButtonItem]>
    internal var barButtonItems: Optional<[UIBarButtonItem]> { toolbar.items }
    /// Optional<SKToolbarDelegate>
    internal weak var delegate: Optional<SKToolbarDelegate> = .none
    
    // MARK: 私有属性
    
    /// 分享按钮
    private lazy var shareItem: UIBarButtonItem = {
        let _img: UIImage = .bundledImage(named: "btn_common_share_wh").redrawWith(.init(width: 34.0, height: 34.0)).withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.tintColor = UIColor.white
        return _item
    }()
    
    /// 下载按钮
    private lazy var downloadItem: UIBarButtonItem = {
        let _img: UIImage = .bundledImage(named: "btn_common_download_wh").redrawWith(.init(width: 34.0, height: 34.0)).withRenderingMode(.alwaysOriginal)
        let _item: UIBarButtonItem = .init(image: _img, style: .plain, target: self, action: #selector(itemActionHandler(_:)))
        _item.tintColor = UIColor.white
        return _item
    }()
    
    /// UIBarButtonItem
    private lazy var loadingItem: UIBarButtonItem = {
        let _loadingView: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            _loadingView = .init(style: .medium)
        } else {
            _loadingView = .init(style: .white)
        }
        _loadingView.color = .white
        _loadingView.hidesWhenStopped = true
        let _item: UIBarButtonItem = .init(customView: _loadingView)
        _item.tag = 3001
        return _item
    }()
    
    /// UIToolbar
    private lazy var toolbar: UIToolbar = {
        let _toolbar: UIToolbar = .init(frame: .zero)
        _toolbar.backgroundColor = .clear
        _toolbar.clipsToBounds = true
        _toolbar.isTranslucent = true
        _toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        return _toolbar
    }()
    
    /// SKPhotoBrowser
    private weak var browser: Optional<SKPhotoBrowser>
    
    // MARK: 生命周期
    
    /// 构建
    /// - Parameters:
    ///   - frame: CGRect
    ///   - browser: SKPhotoBrowser
    internal init(frame: CGRect, browser: SKPhotoBrowser) {
        self.browser = browser
        super.init(frame: frame)
        // 初始化
        initialize()
    }
    
    /// 构建
    /// - Parameter coder: NSCoder
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    /// layoutSubviews
    internal override func layoutSubviews() {
        super.layoutSubviews()
        // update toolbar frame
        toolbar.frame = bounds
    }
}

extension SKToolbar {
    
    /// 初始化
    private func initialize() {
        // add toolbar
        addSubview(toolbar)
        // setupToolbar
        setupToolbar(with: actionKind)
    }
    
    /// setupToolbar
    /// - Parameter actionKind: Optional<ActionKind>
    private func setupToolbar(with actionKind: Optional<ActionKind>) {
        switch actionKind {
        case .some(.share) where SKPhotoBrowserOptions.displayAction == true:
            toolbar.items = [.flexible(), shareItem]
            loadingView?.stopAnimating()
        case .some(.download) where SKPhotoBrowserOptions.displayDownload == true:
            toolbar.items = [.flexible(), downloadItem]
            loadingView?.stopAnimating()
        case .some(.loading):
            toolbar.items = [.flexible(), loadingItem]
            loadingView?.startAnimating()
        default:
            toolbar.items = []
            loadingView?.stopAnimating()
        }
    }
    
    /// itemActionHandler
    /// - Parameter sender: UIBarButtonItem
    @objc private func itemActionHandler(_ sender: UIBarButtonItem) {
        switch sender {
        case shareItem:
            delegate?.toolbar(self, shareActionHandler: sender)
        case downloadItem:
            delegate?.toolbar(self, downloadActionHandler: sender)
        default: break
        }
    }
    
}

