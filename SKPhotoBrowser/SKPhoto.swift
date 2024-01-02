//
//  SKPhoto.swift
//  SKViewExample
//
//  Created by suzuki_keishi on 2015/10/01.
//  Copyright © 2015 suzuki_keishi. All rights reserved.
//

import UIKit
#if canImport(SKPhotoBrowserObjC)
import SKPhotoBrowserObjC
#endif

/// SKPhotoProtocol
public protocol SKPhotoProtocol: AnyObject {
    var index: Int { get set }
    var underlyingImage: Optional<UIImage> { get }
    var caption: Optional<String> { get }
    var contentMode: UIView.ContentMode { get set }
    func loadUnderlyingImageAndNotify()
    func checkCache()
}

extension SKPhotoProtocol {
    
    /// Int
    internal var index: Int { 0 }
    /// Optional<String>
    internal var caption: Optional<String> { .none }
    /// UIView.ContentMode
    internal var contentMode: UIView.ContentMode { .scaleAspectFit }
}

// MARK: - SKPhoto
open class SKPhoto: NSObject, SKPhotoProtocol {
    /// Int
    open var index: Int = 0
    /// Optional<UIImage>
    open var underlyingImage: Optional<UIImage> = .none
    /// Optional<String>
    open var caption: Optional<String> = .none
    /// UIView.ContentMode
    open var contentMode: UIView.ContentMode = .scaleAspectFill
    /// Bool
    open var shouldCachePhotoURLImage: Bool = false
    /// Optional<String>
    open var photoURL: Optional<String> = .none
    
    public override init() {
        super.init()
    }
    
    /// 构建
    /// - Parameter image: UIImage
    public convenience init(image: UIImage) {
        self.init()
        underlyingImage = image
    }
    
    /// 构建
    /// - Parameter url: String
    public convenience init(url: String) {
        self.init()
        photoURL = url
    }
    
    /// 构建
    /// - Parameters:
    ///   - url: String
    ///   - holder: Optional<UIImage>
    public convenience init(url: String, holder: Optional<UIImage>) {
        self.init()
        photoURL = url
        underlyingImage = holder
    }
    
    /// checkCache
    open func checkCache() {
        guard let photoURL = photoURL else { return }
        guard shouldCachePhotoURLImage else { return }
        if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
            let request = URLRequest(url: URL(string: photoURL)!)
            if let img = SKCache.sharedCache.imageForRequest(request) {
                underlyingImage = img
            }
        } else {
            if let img = SKCache.sharedCache.imageForKey(photoURL) {
                underlyingImage = img
            }
        }
    }
    
    /// loadUnderlyingImageAndNotify
    open func loadUnderlyingImageAndNotify() {
        guard let photoURL = photoURL, let URL = URL(string: photoURL) else { return }
        if self.shouldCachePhotoURLImage {
            if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                let request = URLRequest(url: URL)
                if let img = SKCache.sharedCache.imageForRequest(request) {
                    DispatchQueue.main.async {[weak self] in
                        self?.underlyingImage = img
                        self?.loadUnderlyingImageComplete()
                    }
                    return
                }
            } else {
                if let img = SKCache.sharedCache.imageForKey(photoURL) {
                    DispatchQueue.main.async {[weak self] in
                        self?.underlyingImage = img
                        self?.loadUnderlyingImageComplete()
                    }
                    return
                }
            }
        }
        
        // Fetch Image
        let session = URLSession(configuration: SKPhotoBrowserOptions.sessionConfiguration)
        var task: Optional<URLSessionDataTask> = .none
        task = session.dataTask(with: URL, completionHandler: { [weak self] (data, response, error) in
            guard let this = self else { return }
            defer { session.finishTasksAndInvalidate() }
            guard error == nil else {
                DispatchQueue.main.async {[weak this] in
                    this?.loadUnderlyingImageComplete()
                }
                return
            }
            if let data = data, let response = response, let image = UIImage.animatedImage(withAnimatedGIFData: data) {
                if this.shouldCachePhotoURLImage {
                    if SKCache.sharedCache.imageCache is SKRequestResponseCacheable {
                        SKCache.sharedCache.setImageData(data, response: response, request: task?.originalRequest)
                    } else {
                        SKCache.sharedCache.setImage(image, forKey: photoURL)
                    }
                }
                DispatchQueue.main.async {[weak this] in
                    this?.underlyingImage = image
                    this?.loadUnderlyingImageComplete()
                }
            }
            
        })
        task?.resume()
    }
    
    /// loadUnderlyingImageComplete
    open func loadUnderlyingImageComplete() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: SKPHOTO_LOADING_DID_END_NOTIFICATION), object: self)
    }
    
}

// MARK: - Static Function

extension SKPhoto {
    
    /// photoWithImage
    /// - Parameter image: UIImage
    /// - Returns: SKPhoto
    public static func photoWithImage(_ image: UIImage) -> SKPhoto {
        return SKPhoto(image: image)
    }
    
    /// photoWithImageURL
    /// - Parameter url: String
    /// - Returns: SKPhoto
    public static func photoWithImageURL(_ url: String) -> SKPhoto {
        return SKPhoto(url: url)
    }
    
    /// photoWithImageURL
    /// - Parameters:
    ///   - url: String
    ///   - holder: UIImage
    /// - Returns: SKPhoto
    public static func photoWithImageURL(_ url: String, holder: UIImage?) -> SKPhoto {
        return SKPhoto(url: url, holder: holder)
    }
}
