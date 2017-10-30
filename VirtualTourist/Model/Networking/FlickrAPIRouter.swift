//
//  FlickerAPIClient.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import Foundation

enum FlickrAPIRouter
{
    // Possible requests
    case searchPhotos(apiKey: String, bbox: (minLong: Double, minLat: Double, maxLong: Double, maxLat: Double))
    case searchPhotosInPage(apiKey: String, bbox: (minLong: Double, minLat: Double, maxLong: Double, maxLat: Double), page: Int)
    
    // Base URL
    static let baseURLString = "https://api.flickr.com"
    
    // Method
    var method: String {
        switch self
        {
        case .searchPhotos, .searchPhotosInPage:
            return "GET"
        }
    }
    
    // Relative path
    var relativePath: String {
        switch self
        {
        case .searchPhotos, .searchPhotosInPage:
            return "/services/rest/"
        }
    }
    
    // Query Items
    var quryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        switch self
        {
        case .searchPhotos(apiKey: let apiKey, bbox: (minLong: let minLong, minLat: let minLat, maxLong: let maxLong, maxLat: let maxLat)):
            items.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
            items.append(URLQueryItem(name: "api_key", value: apiKey))
            items.append(URLQueryItem(name: "format", value: "json"))
            items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
            items.append(URLQueryItem(name: "bbox", value: "\(minLong),\(minLat),\(maxLong),\(maxLat)"))
            
        case .searchPhotosInPage(apiKey: let apiKey, bbox: (minLong: let minLong, minLat: let minLat, maxLong: let maxLong, maxLat: let maxLat), page: let page):
            items.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
            items.append(URLQueryItem(name: "api_key", value: apiKey))
            items.append(URLQueryItem(name: "format", value: "json"))
            items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
            items.append(URLQueryItem(name: "bbox", value: "\(minLong),\(minLat),\(maxLong),\(maxLat)"))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        return items
    }
    
    // Parameters
    var parameters: Data? {
        
        return nil
    }
    
    func asUrlRequest() -> URLRequest
    {
        var urlComponents = URLComponents(string: FlickrAPIRouter.baseURLString)
        urlComponents?.path = relativePath
        urlComponents?.queryItems = quryItems
        let url = urlComponents?.url
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.httpBody = parameters
        
        return request
    }
}
    

