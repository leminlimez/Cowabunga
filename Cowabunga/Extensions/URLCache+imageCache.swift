//
//  URLCache+imageCache.swift
//  Cowabunga
//
//  Created by sourcelocation on 02/02/2023.
//

import CachedAsyncImage

extension URLCache {
    
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
