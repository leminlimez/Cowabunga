//
//  AssetCatalogManager.swift
//  Cowabunga
//
//  Created by lemin on 3/6/23.
//

import Foundation
import AssetCatalogWrapper

class AssetCatalogManager {
    public static func getAssetRenditions(_ url: URL) -> [Rendition] {
        do {
            var returningRenditions: [Rendition] = []
            let (_, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: url)
            for rendition in renditionsRoot {
                let type = rendition.type
                if type == .icon || type == .image {
                    let renditions = rendition.renditions
                    for rend in renditions {
                        returningRenditions.append(rend)
                    }
                }
            }
            return returningRenditions
        } catch {
            return []
        }
    }
}
