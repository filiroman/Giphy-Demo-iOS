//
//  AnimationLoadingOperation.swift
//  Giphy Demo
//
//  Created by Roman on 13.04.2023.
//

import Foundation

final class AnimationLoadingOperation: Operation {
    private(set) var animationData: Data?
    var loadingCompleteHandler: ((Data) -> Void)? {
        didSet {
            if let animationData, isFinished {
                loadingCompleteHandler?(animationData)
            }
        }
    }
    
    private let url: URL
    private var dataDask: URLSessionDataTask?
    
    init(url: URL) {
        self.url = url
    }
    
    override func main() {
        guard !isCancelled else { return }

        // First check if url is cached already
        if let data = AnimationsCache.standard.getAnimation(forURL: url) {
            guard !isCancelled else { return }
            self.animationData = data
            loadingCompleteHandler?(data)
            return
        }
        // If not cached - load from url, but keep track on task so we can cancel it
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let strong = self else { return }
            guard !strong.isCancelled else { return }
            guard let data else { return }
            // Cache image after downloading
            AnimationsCache.standard.cacheAnimation(data, forURL: strong.url)
            strong.animationData = data
            strong.loadingCompleteHandler?(data)
        }
        dataDask = task
        task.resume()
    }
    
    override func cancel() {
        super.cancel()
        dataDask?.cancel()
    }
}
