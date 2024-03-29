//
//  UIImage+StandardSize.swift
//  ding
//
//  Created by Yunpeng Niu on 14/04/18.
//  Copyright © 2018 CS3217 Ding. All rights reserved.
//

import UIKit

/**
 Extension for `UIImage` to provide some utility methods for image resize.

 - Author: Group 3 @ CS3217
 - Date: March 2018
 */
extension UIImage {
    /// The standard image size in KB.
    private static let standardImageSize = 1_024

    /// Compress an image to avoid large-size image
    /// - Return: the data of compressed image, nil if it cannot be compressed
    public var standardData: Data? {
        let originalImageSize = self.size.width * self.size.height
        var quality = CGFloat(UIImage.standardImageSize) / originalImageSize
        if quality > 1 {
            quality = 1
        }
        return UIImageJPEGRepresentation(self, quality)
    }
}
