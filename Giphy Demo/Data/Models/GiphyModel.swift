//
//  GiphyModel.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation

struct GiphyModel {
    let internalId = UUID().uuidString
    let _id: String
    let slug: String
    let preview: GiphyImageModel
    let highQuality: GiphyImageModel
    let giphyURL: URL
}

extension GiphyModel: Hashable {
    static func == (lhs: GiphyModel, rhs: GiphyModel) -> Bool {
        return lhs.internalId == rhs.internalId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(internalId)
    }
}
