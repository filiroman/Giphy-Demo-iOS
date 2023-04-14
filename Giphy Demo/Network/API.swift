//
//  API.swift
//  Giphy Demo
//
//  Created by Roman on 12.04.2023.
//

import Foundation

final class API {
    private enum Constants {
        static let apiURL = "https://api.giphy.com/v1/"
        static let apiKey = "XMFKiA7FXISH0L4sqkqo3NTCCdMR4SIj"
    }
    
    private enum Paths {
        static let gifTrending = "gifs/trending"
    }
    
    static func getTrending(offset: Int, limit: Int, completion: @escaping(Result<TrendingResponse, Error>) -> Void) {
        guard var apiURL = URL(string: Constants.apiURL) else {
            completion(.failure(NSError(domain: "Wrong API URL", code: -1)))
            return
        }
        apiURL.append(path: Paths.gifTrending)
        let queryItems: [URLQueryItem] = [URLQueryItem(name: "api_key", value: Constants.apiKey),
                                          URLQueryItem(name: "offset", value: String(offset)),
                                          URLQueryItem(name: "limit", value: String(limit))]
        apiURL.append(queryItems: queryItems)
        let urlRequest = URLRequest(url: apiURL)
        print("Sending API Request: \(apiURL.absoluteString)")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let data else {
                completion(.failure(NSError(domain: "Empty data returned", code: 0)))
                return
            }
            do {
                let trending = try JSONDecoder().decode(TrendingResponse.self, from: data)
                completion(.success(trending))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
