//
//  SKPhotoBrowserDelegate.swift
//  SKPhotoBrowser
//
//  Created by 鈴木 啓司 on 2016/08/09.
//  Copyright © 2016年 suzuki_keishi. All rights reserved.
//

import UIKit

@objc public protocol SKPhotoBrowserDelegate {
    
    /// Tells the delegate that the browser started displaying a new photo
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    @objc optional func browser(_ browser: SKPhotoBrowser, didShowPhotoAtIndex index: Int)
    
    /// Tells the delegate the browser will start to dismiss
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    @objc optional func browser(_ browser: SKPhotoBrowser, willDismissAtPageIndex index: Int)
    
    /// Tells the delegate that the browser will start showing the `UIActionSheet`
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - photoIndex: Int
    @objc optional func browser(_ browser: SKPhotoBrowser, willShowActionSheetAtIndex photoIndex: Int)
    
    /// Tells the delegate that the browser has been dismissed
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    @objc optional func browser(_ browser: SKPhotoBrowser, didDismissAtPageIndex index: Int)
    
    /// Tells the delegate that the browser did dismiss the UIActionSheet
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - buttonIndex: the index of the pressed button
    ///   - photoIndex:  the index of the current photo
    @objc optional func browser(_ browser: SKPhotoBrowser, didDismissActionSheetWithButtonIndex buttonIndex: Int, photoIndex: Int)

    /// Tells the delegate that the browser did scroll to index
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: Int
    @objc optional func browser(_ browser: SKPhotoBrowser, didScrollToIndex index: Int)
    
    /// Tells the delegate the user removed a photo, when implementing this call, be sure to call reload to finish the deletion process
    /// - Parameters:
    ///   - browser: reference to the calling SKPhotoBrowser
    ///   - index: the index of the removed photo
    ///   - reload: function that needs to be called after finishing syncing up
    @objc optional func browser(_ browser: SKPhotoBrowser, removePhotoAtIndex index: Int, reload: @escaping (() -> Void))

    /// Asks the delegate for the view for a certain photo. Needed to detemine the animation when presenting/closing the browser.
    /// - Parameters:
    ///   - browser: reference to the calling SKPhotoBrowser
    ///   - index: the index of the removed photo
    /// - Returns: the view to animate to
    @objc optional func browser(_ browser: SKPhotoBrowser, viewForPhotoAtIndex index: Int) -> Optional<UIView>

    /// Tells the delegate that the controls view toggled visibility
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - hidden: Bool
    @objc optional func browser(_ browser: SKPhotoBrowser, controlsVisibilityToggled hidden: Bool)
 
    /// Allows  the delegate to create its own caption view
    /// - Parameters:
    ///   - browser: SKPhotoBrowser
    ///   - index: the index of the photo
    /// - Returns: Optional<SKCaptionView>
    @objc optional func browser(_ browser: SKPhotoBrowser, captionViewForPhotoAtIndex index: Int) -> Optional<SKCaptionView>
}

