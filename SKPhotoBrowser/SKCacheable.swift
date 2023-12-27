//
//  SKCacheable.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit.UIImage

public protocol SKCacheable {}
public protocol SKImageCacheable: SKCacheable {
    
    /// imageForKey
    /// - Parameter key: String
    /// - Returns: Optional<UIImage>
    func imageForKey(_ key: String) -> Optional<UIImage>
    
    /// setImage
    /// - Parameters:
    ///   - image: UIImage
    ///   - key: String
    func setImage(_ image: UIImage, forKey key: String)
    
    /// removeImageForKey
    /// - Parameter key: String
    func removeImageForKey(_ key: String)
    
    /// removeAllImages
    func removeAllImages()
}

public protocol SKRequestResponseCacheable: SKCacheable {
    
    /// cachedResponseForRequest
    /// - Parameter request: URLRequest
    /// - Returns: CachedURLResponse
    func cachedResponseForRequest(_ request: URLRequest) -> Optional<CachedURLResponse>
    
    /// storeCachedResponse
    /// - Parameters:
    ///   - cachedResponse: CachedURLResponse
    ///   - request: CachedURLResponse
    func storeCachedResponse(_ cachedResponse: CachedURLResponse, forRequest request: URLRequest)
}
