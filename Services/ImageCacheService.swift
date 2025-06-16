//
//  ImageCacheService.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import Foundation
import UIKit
import Combine

class ImageCacheService: ObservableObject {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func loadImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        // Check cache first
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            return Just(cachedImage)
                .eraseToAnyPublisher()
        }
        
        // Download image if not cached
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { data, _ in
                guard let image = UIImage(data: data) else { return nil }
                // Cache the image
                self.cache.setObject(image, forKey: urlString as NSString)
                return image
            }
            .catch { _ in Just(nil) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
