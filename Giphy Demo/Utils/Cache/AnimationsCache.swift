//
//  ImageCache.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation
import UIKit

final class AnimationsCache {
    static let standard = AnimationsCache()
    
    private let cachedAnimations = NSCache<NSURL, NSData>()
    
    private init() {
        // 50 mb
        cachedAnimations.totalCostLimit = 50*1024*1024
    }
    
    func getAnimation(forURL url: URL) -> Data? {
        return cachedAnimations.object(forKey: (url as NSURL)) as? Data
    }
    
    func cacheAnimation(_ animationData: Data, forURL url: URL) {
        cachedAnimations.setObject(animationData as NSData, forKey: url as NSURL, cost: animationData.count)
    }
}
