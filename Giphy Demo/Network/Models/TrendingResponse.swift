//
//  TrendingResponse.swift
//  Giphy Demo
//
//  Created by Roman on 11.04.2023.
//

import Foundation

struct TrendingResponse: Decodable {
    struct DataItem: Decodable {
        struct Images: Decodable {
            struct ImageItem: Decodable {
                let height: String
                let width: String
                let url: URL
            }
            
            let original: ImageItem
            let fixedWidthDownsampled: ImageItem
            
            enum CodingKeys: String, CodingKey {
                case original
                case fixedWidthDownsampled = "fixed_width_downsampled"
            }
        }
        
        let _id: String
        let slug: String
        let images: Images
        let url: URL
        
        enum CodingKeys: String, CodingKey {
            case _id = "id"
            case slug
            case images
            case url
        }
    }
    
    struct Pagination: Decodable {
        let totalCount: Int
        let count: Int
        let offset: Int
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case count
            case offset
        }
    }
    
    let data: [DataItem]
}
