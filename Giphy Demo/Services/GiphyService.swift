//
//  GiphyService.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation

// Converts API Responses to Internal App Models
final class GiphyService {
    class func getTrendingGiphy(offset: Int, limit: Int, completion: @escaping(Result<[GiphyModel], Error>) -> Void) {
        API.getTrending(offset: offset, limit: limit) { result in
            switch result {
            case .failure(let err):
                completion(.failure(err))
            case .success(let response):
                var results: [GiphyModel] = []
                for next in response.data {
                    let previewModel = GiphyImageModel(width: next.images.fixedWidthDownsampled.width.cgFloatValue,
                                                       height: next.images.fixedWidthDownsampled.height.cgFloatValue,
                                                       url: next.images.fixedWidthDownsampled.url)
                    let highQualityModel = GiphyImageModel(width: next.images.original.width.cgFloatValue,
                                                           height: next.images.original.height.cgFloatValue,
                                                           url: next.images.original.url)
                    let model = GiphyModel(_id: next._id,
                                           slug: next.slug,
                                           preview: previewModel,
                                           highQuality: highQualityModel,
                                           giphyURL: next.url)
                    results.append(model)
                }
                completion(.success(results))
            }
        }
    }
}
