//
//  UIImage+Extends.swift
//  SKPhotoBrowser
//
//  Created by iferret on 2023/12/27.
//  Copyright © 2023 suzuki_keishi. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// redrawWith
    /// - Parameter size: CGSize
    /// - Returns: UIImage
    internal func redrawWith(_ size: CGSize) -> UIImage {
        let render: UIGraphicsImageRenderer = .init(size: size, format: .preferred())
        return render.image { ctx in
            self.draw(in: .init(origin: .zero, size: size))
        }
    }
}
