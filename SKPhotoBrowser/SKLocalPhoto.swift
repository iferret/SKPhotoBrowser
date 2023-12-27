//
//  SKLocalPhoto.swift
//  SKPhotoBrowser
//
//  Created by Antoine Barrault on 13/04/2016.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

/// SKLocalPhoto
open class SKLocalPhoto: NSObject, SKPhotoProtocol {
    
    /// Optional<UIImage>
    open var underlyingImage: Optional<UIImage> = .none
    
    /// Optional<String>
    open var photoURL: Optional<String> = .none
    
    /// UIView.ContentMode
    open var contentMode: UIView.ContentMode = .scaleToFill
    
    /// Bool
    open var shouldCachePhotoURLImage: Bool = false
    
    /// Optional<String>
    open var caption: Optional<String> = .none
    
    /// Int
    open var index: Int = 0
    
    /// 构建
    override init() {
        super.init()
    }
    
    /// 构建
    /// - Parameter url: String
    convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    /// 构建
    /// - Parameters:
    ///   - url: String
    ///   - holder: Optional<UIImage>
    convenience init(url: String, holder: Optional<UIImage>) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    /// checkCache
    open func checkCache() {}
    
    /// loadUnderlyingImageAndNotify
    open func loadUnderlyingImageAndNotify() {
        if underlyingImage != nil && photoURL == nil {
            loadUnderlyingImageComplete()
        }
        guard let photoURL = photoURL, FileManager.default.fileExists(atPath: photoURL) == true else { return }
        guard let data: Data = FileManager.default.contents(atPath: photoURL) else { return }
        loadUnderlyingImageComplete()
        if let image = UIImage(data: data) {
            underlyingImage = image
            loadUnderlyingImageComplete()
        }
    }
    
    /// loadUnderlyingImageComplete
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
    // MARK: - class func
    
    /// photoWithImageURL
    /// - Parameter url: SKLocalPhoto
    /// - Returns: String
    open class func photoWithImageURL(_ url: String) -> SKLocalPhoto {
        return SKLocalPhoto(url: url)
    }
    
    /// photoWithImageURL
    /// - Parameters:
    ///   - url: String
    ///   - holder: UIImage
    /// - Returns: SKLocalPhoto
    open class func photoWithImageURL(_ url: String, holder: UIImage?) -> SKLocalPhoto {
        return SKLocalPhoto(url: url, holder: holder)
    }
}
