//
//  SKPaginationView.swift
//  SKPhotoBrowser
//
//  Created by keishi_suzuki on 2017/12/20.
//  Copyright © 2017年 suzuki_keishi. All rights reserved.
//

import UIKit

class SKPaginationView: UIView {
    
    /// Optional<UILabel>
    internal var counterLabel: Optional<UILabel> = .none
    /// Optional<UIButton>
    internal var prevButton: Optional<UIButton> = .none
    /// Optional<UIButton>
    internal var nextButton: Optional<UIButton> = .none
    /// CGFloat
    private var margin: CGFloat = 100.0
    /// CGFloat
    private var extraMargin: CGFloat = SKMesurement.isPhoneX ? 40 : 0
    //// SKPhotoBrowser
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
    internal convenience init(frame: CGRect, browser: Optional<SKPhotoBrowser>) {
        self.init(frame: frame)
        self.frame = CGRect(x: 0, y: frame.height - margin - extraMargin, width: frame.width, height: 100)
        self.browser = browser
        
        setupApperance()
        setupCounterLabel()
        setupPrevButton()
        setupNextButton()
        
        update(browser?.currentPageIndex ?? 0)
    }
    
    /// hitTest
    /// - Parameters:
    ///   - point: CGPoint
    ///   - event: UIEvent
    /// - Returns: UIView
    internal override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if let counterLabel = counterLabel, counterLabel.frame.contains(point) {
                return view
            } else if let prevButton = prevButton, prevButton.frame.contains(point) {
                return view
            } else if let nextButton = nextButton, nextButton.frame.contains(point) {
                return view
            }
            return nil
        }
        return nil
    }
    
    /// updateFrame
    /// - Parameter frame: CGRect
    internal func updateFrame(frame: CGRect) {
        self.frame = CGRect(x: 0, y: frame.height - margin, width: frame.width, height: 100)
    }
    
    /// update
    /// - Parameter currentPageIndex: Int
    internal func update(_ currentPageIndex: Int) {
        guard let browser = browser else { return }
        
        if browser.photos.count > 1 {
            counterLabel?.text = "\(currentPageIndex + 1) / \(browser.photos.count)"
        } else {
            counterLabel?.text = nil
        }
        
        guard let prevButton = prevButton, let nextButton = nextButton else { return }
        prevButton.isEnabled = (currentPageIndex > 0)
        nextButton.isEnabled = (currentPageIndex < browser.photos.count - 1)
    }
    
    /// setControlsHidden
    /// - Parameter hidden: Bool
    internal func setControlsHidden(hidden: Bool) {
        // animate
        UIView.animate(withDuration: 0.35) {
            self.alpha = hidden == true ? 0.0 : 1.0
        }
    }
}

extension SKPaginationView {
    
    /// setupApperance
    private func setupApperance() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    /// setupCounterLabel
    private func setupCounterLabel() {
        guard SKPhotoBrowserOptions.displayCounterLabel else { return }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.shadowColor = SKToolbarOptions.textShadowColor
        label.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label.font = SKToolbarOptions.font
        label.textColor = SKToolbarOptions.textColor
        label.translatesAutoresizingMaskIntoConstraints = true
        label.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        addSubview(label)
        counterLabel = label
    }
    
    /// setupPrevButton
    private func setupPrevButton() {
        guard SKPhotoBrowserOptions.displayBackAndForwardButton else { return }
        guard browser?.photos.count ?? 0 > 1 else { return }
        
        let button = SKPrevButton(frame: frame)
        button.center = CGPoint(x: frame.width / 2 - 100, y: frame.height / 2)
        button.addTarget(browser, action: #selector(SKPhotoBrowser.gotoPreviousPage), for: .touchUpInside)
        addSubview(button)
        prevButton = button
    }
    
    /// setupNextButton
    private func setupNextButton() {
        guard SKPhotoBrowserOptions.displayBackAndForwardButton else { return }
        guard browser?.photos.count ?? 0 > 1 else { return }
        
        let button = SKNextButton(frame: frame)
        button.center = CGPoint(x: frame.width / 2 + 100, y: frame.height / 2)
        button.addTarget(browser, action: #selector(SKPhotoBrowser.gotoNextPage), for: .touchUpInside)
        addSubview(button)
        nextButton = button
    }
}

/// setupNextButton
class SKPaginationButton: UIButton {
    
    /// UIEdgeInsets
    internal let insets: UIEdgeInsets = .init(top: 13.25, left: 17.25, bottom: 13.25, right: 17.25)
    
    /// setup
    /// - Parameter imageName: String
    internal func setup(_ imageName: String) {
        backgroundColor = .clear
        imageEdgeInsets = insets
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        contentMode = .center
        setImage(UIImage.bundledImage(named: imageName), for: .normal)
    }
}

/// SKPrevButton
class SKPrevButton: SKPaginationButton {
    
    /// String
    internal let imageName: String = "btn_common_back_wh"
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}

/// SKNextButton
class SKNextButton: SKPaginationButton {
    
    /// String
    internal let imageName: String = "btn_common_forward_wh"
    
    /// 构建
    /// - Parameter aDecoder: NSCoder
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 构建
    /// - Parameter frame: CGRect
    internal override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        setup(imageName)
    }
}
