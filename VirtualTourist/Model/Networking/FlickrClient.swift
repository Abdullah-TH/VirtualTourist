//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Abdullah Althobetey on 10/11/17.
//  Copyright © 2017 Abdullah Althobetey. All rights reserved.
//

import Foundation

class FlickrClient
{
    /// Get 21 random photos inside the specified bbox
    static func getPhotosBy(minLong: Double, minLat: Double, maxLong: Double, maxLat: Double, completionHandler completion: @escaping (_ error: Error?, _ photoURLs: [URL]?) -> Void)
    {
        let request = FlickrAPIRouter.searchPhotos(apiKey: "3f695e85f4ddb49365f3f7b673d4a86a", bbox: (minLong: minLong, minLat: minLat, maxLong: maxLong, maxLat: maxLat)).asUrlRequest()
        print(request.url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(message: String)
            {
                let error = NSError(domain: "getPhotosBy", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
                completion(error, nil)
            }
            
            guard error == nil else
            {
                completion(error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else
            {
                sendError(message: "Error: Got status code other than 200\n Status code is: \((response as! HTTPURLResponse).statusCode)")
                return
            }
            
            guard let data = data else
            {
                sendError(message: "Error: No data received.")
                return
            }
            
            do
            {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                guard let jsonDictionary = jsonObject as? [String: Any] else
                {
                    sendError(message: "Cannot cast json to [String: Any]")
                    return
                }
                
                guard let photosDictionary = jsonDictionary["photos"] as? [String: Any] else
                {
                    sendError(message: "Cannot get the 'photos' dictionary")
                    return
                }
                
                guard let photoArray = photosDictionary["photo"] as? [[String: Any]] else
                {
                    sendError(message: "Cannot get the 'photo' array")
                    return
                }
                
                let photoURLs = getRandomPhotoURLs(photoArray: photoArray, max: 21)
                completion(nil, photoURLs)
            }
            catch let error
            {
                completion(error, nil)
                return
            }
        }
        
        task.resume()
    }
    
    private static func getRandomPhotoURLs(photoArray: [[String: Any]], max: Int) -> [URL]
    {
        var photoURLs = [URL]()
        
        if photoArray.count > max
        {
            let randomIndexes = generateDistinctRandomInt(upperBound: photoArray.count)
            for index in randomIndexes
            {
                let photoDict = photoArray[index]
                if let url = getPhotoURL(from: photoDict)
                {
                    photoURLs.append(url)
                }
            }
        }
        else
        {
            for photoDict in photoArray
            {
                if let url = getPhotoURL(from: photoDict)
                {
                    photoURLs.append(url)
                }
                
                if photoURLs.count == max { break }
            }
        }
        
        return photoURLs
    }
    
    private static func generateDistinctRandomInt(upperBound: Int) -> [Int]
    {
        var randomIndexes = [Int]()
        while true
        {
            let randomNumber = Int(arc4random_uniform(UInt32(upperBound)))
            if randomIndexes.contains(randomNumber)
            {
                continue
            }
            else
            {
                randomIndexes.append(randomNumber)
                if randomIndexes.count == 21
                {
                    break
                }
            }
        }
        return randomIndexes
    }
    
    private static func getPhotoURL(from photoDictionary: [String: Any]) -> URL?
    {
        if let id = photoDictionary["id"] as? String,
            let secret = photoDictionary["secret"] as? String,
            let server = photoDictionary["server"] as? String,
            let farm = photoDictionary["farm"] as? Int
        {
            let url = constructFlickrPhotoURL(id: id, secret: secret, server: server, farm: farm)
            return url
        }
        return nil
    }
    
    private static func constructFlickrPhotoURL(id: String, secret: String, server: String, farm: Int) -> URL?
    {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
    }
}












