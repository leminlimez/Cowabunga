//
//  UIImage+resizeToApprox.swift
//  Cowabunga
//
//  Created by sourcelocation on 03/02/2023.
//

import UIKit

extension UIImage {
    func resizeToApprox(allowedSizeInBytes: Int) throws -> Data {
        if let data = self.jpegData(compressionQuality: 0.99), data.count <= allowedSizeInBytes {
            return data
        }
        
        print("starting resizeToApprox. max size = \(allowedSizeInBytes)")
        var left:CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        
        var closestImage: Data?
        guard var newResImage = self.jpegData(compressionQuality: 1) else { throw "could not compress image" }

        for i in 0...13 {
            print("mid = \(mid), i = \(i), closestImage->count = \(closestImage?.count ?? 0), newResImage->count = \(newResImage.count)")
            
            if newResImage.count < allowedSizeInBytes {
                left = mid
            } else if newResImage.count > allowedSizeInBytes {
                right = mid
            } else {
                // miracle happens
                return newResImage
            }
            
            mid = (left + right) / 2.0
            guard let newData = self.jpegData(compressionQuality: mid) else { throw "could not compress image" }
            if newData.count < allowedSizeInBytes {
                closestImage = newData
            }
            newResImage = newData
        }
        if let closestImage = closestImage {
            return closestImage
        } else {
            throw "Could not compress image low enough to fit inside the original \(allowedSizeInBytes) bytes"
        }
    }
}
