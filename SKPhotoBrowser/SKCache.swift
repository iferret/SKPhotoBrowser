//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

open class SKCache {
    /// SKCache
    public static let sharedCache: SKCache = .init()
    /// SKCacheable
    open var imageCache: SKCacheable
    
    /// 构建
    init() {
        self.imageCache = SKDefaultImageCache()
    }
    
    /// imageForKey
    /// - Parameter key: String
    /// - Returns: UIImage
    open func imageForKey(_ key: String) -> Optional<UIImage> {
        guard let cache = imageCache as? SKImageCacheable else { return .none }
        return cache.imageForKey(key)
    }
    
    /// setImage
    /// - Parameters:
    ///   - image: UIImage
    ///   - key: String
    open func setImage(_ image: UIImage, forKey key: String) {
        guard let cache = imageCache as? SKImageCacheable else { return }
        cache.setImage(image, forKey: key)
    }
    
    /// removeImageForKey
    /// - Parameter key: String
    open func removeImageForKey(_ key: String) {
        guard let cache = imageCache as? SKImageCacheable else { return }
        cache.removeImageForKey(key)
    }
    
    /// removeAllImages
    open func removeAllImages() {
        guard let cache = imageCache as? SKImageCacheable else { return }
        cache.removeAllImages()
    }
    
    /// imageForRequest
    /// - Parameter request: URLRequest
    /// - Returns: Optional<UIImage>
    open func imageForRequest(_ request: URLRequest) -> Optional<UIImage> {
        guard let cache = imageCache as? SKRequestResponseCacheable else { return .none }
        if let response = cache.cachedResponseForRequest(request) {
            return UIImage(data: response.data)
        }
        return .none
    }
    
    /// setImageData
    /// - Parameters:
    ///   - data: Data
    ///   - response: URLResponse
    ///   - request:  Optional<URLRequest>
    open func setImageData(_ data: Data, response: URLResponse, request: Optional<URLRequest>) {
        guard let cache = imageCache as? SKRequestResponseCacheable, let request = request else { return }
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

/// SKDefaultImageCache
class SKDefaultImageCache: SKImageCacheable {
    
    /// NSCache<AnyObject, AnyObject>
    internal var cache: NSCache<AnyObject, AnyObject>
    
    /// 构建
    internal init() {
        cache = NSCache()
    }
    
    /// imageForKey
    /// - Parameter key: String
    /// - Returns: Optional<UIImage>
    internal func imageForKey(_ key: String) -> Optional<UIImage> {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }
    
    /// setImage
    /// - Parameters:
    ///   - image: UIImage
    ///   - key: String
    internal func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as AnyObject)
    }
    
    /// removeImageForKey
    /// - Parameter key: String
    internal func removeImageForKey(_ key: String) {
        cache.removeObject(forKey: key as AnyObject)
    }
    
    /// removeAllImages
    internal func removeAllImages() {
        cache.removeAllObjects()
    }
}
