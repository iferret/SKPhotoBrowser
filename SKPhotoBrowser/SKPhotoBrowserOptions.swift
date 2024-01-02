//
//  SKPhotoBrowserOptions.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/18.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

public struct SKPhotoBrowserOptions {
    /// Bool
    public static var displayStatusbar: Bool = false
    /// Bool
    public static var displayCloseButton: Bool = true
    /// Bool
    public static var displayDeleteButton: Bool = false
    /// Bool
    public static var displayAction: Bool = true
    /// Bool
    public static var displayDownload: Bool = true
    /// Optional<String>
    public static var shareExtraCaption: Optional<String> = .none
    /// Bool
    public static var displayCounterLabel: Bool = true
    /// Bool
    public static var displayBackAndForwardButton: Bool = true
    
    /// Bool
    public static var displayHorizontalScrollIndicator: Bool = true
    /// Bool
    public static var displayVerticalScrollIndicator: Bool = true
    /// Bool
    public static var displayPagingHorizontalScrollIndicator: Bool = true
    
    /// Bool
    public static var bounceAnimation: Bool = false
    /// Bool
    public static var enableZoomBlackArea: Bool = true
    /// Bool
    public static var enableSingleTapDismiss: Bool = false
    
    /// UIColor
    public static var backgroundColor: UIColor = .black
    /// UIColor
    public static var indicatorColor: UIColor = .white
    /// UIColor
    public static var indicatorStyle: UIActivityIndicatorView.Style = .whiteLarge

    /// By default close button is on left side and delete button is on right.
    ///
    /// Set this property to **true** for swap they.
    ///
    /// Default: false
    public static var swapCloseAndDeleteButtons: Bool = false
    public static var disableVerticalSwipe: Bool = false

    /// if this value is true, the long photo width will match the screen,
    /// and the minScale is 1.0, the maxScale is 2.5
    /// Default: false
    public static var longPhotoWidthMatchScreen: Bool = false

    /// Provide custom session configuration (eg. for headers, etc.)
    public static var sessionConfiguration: URLSessionConfiguration = .default
}

public struct SKButtonOptions {
    
    /// CGPoint
    public static var closeButtonPadding: CGPoint = CGPoint(x: 5, y: 20)
    /// CGPoint
    public static var deleteButtonPadding: CGPoint = CGPoint(x: 5, y: 20)
}

/// SKCaptionOptions
public struct SKCaptionOptions {
    
    /// CaptionLocation
    public enum CaptionLocation {
        case basic
        case bottom
    }
    
    /// UIColor
    public static var textColor: UIColor = .white
    /// NSTextAlignment
    public static var textAlignment: NSTextAlignment = .center
    /// Int
    public static var numberOfLine: Int = 3
    /// NSLineBreakMode
    public static var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    /// UIFont
    public static var font: UIFont = .systemFont(ofSize: 17.0)
    /// UIColor
    public static var backgroundColor: UIColor = .clear
    /// CaptionLocation
    public static var captionLocation: CaptionLocation = .basic
}

public struct SKToolbarOptions {
    /// UIColor
    public static var textColor: UIColor = .white
    /// UIFont
    public static var font: UIFont = .systemFont(ofSize: 17.0)
    /// UIColor
    public static var textShadowColor: UIColor = .black
}
