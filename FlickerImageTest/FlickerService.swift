//
//  FlickerService.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import UIKit

protocol FlickerService: AnyObject {
  func getItemsBySearching(forTags tagList: String, completionHandler: @escaping (Result<FlickrResponse, Error>) -> Void)
  func fetchImage(forURL url: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void)
}

class RealFlickerService: FlickerService {
  var imageCache: [String: UIImage] = [:]
  var inProgressImageFetches: [String: [(Result<UIImage, Error>) -> Void]] = [:]
  let searchURL = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags="

  func getItemsBySearching(forTags tagList: String, completionHandler: @escaping (Result<FlickrResponse, Error>) -> Void) {
    guard let requestURL = URL(string: searchURL+tagList) else {
      completionHandler(.failure(NSError(domain: "Bad URL", code: -1)))
      return
    }

    let request = URLRequest(url: requestURL)
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data,
            let flickrResponse = try? JSONDecoder().decode(FlickrResponse.self, from: data) else {
        completionHandler(.failure(NSError(domain: "Invalid Response", code: -3)))
        return
      }
      completionHandler(.success(flickrResponse))
    }.resume()
  }
  
  func fetchImage(forURL url: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
    // Check if we already have the image
    if let image = imageCache[url] {
      DispatchQueue.main.async {
        completionHandler(.success(image))
      }
      return
    }
    guard let requestURL = URL(string: url) else {
      completionHandler(.failure(NSError(domain: "Bad URL", code: -1)))
      return
    }
    // Check if we have existing requests. If we do, add to a list of completionHandlers
    // If we don't, create the list with this one
    if inProgressImageFetches[url] == nil {
      inProgressImageFetches[url] = [completionHandler]
    } else {
      inProgressImageFetches[url]?.append(completionHandler)
    }
    // Build and run the request
    let request = URLRequest(url: requestURL)
    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      // Inner function we only need in this context to run through all completions when the initial request returns
      func runCompletions(withResult result: Result<UIImage, Error>) {
        for completion in self?.inProgressImageFetches[url] ?? [] {
          DispatchQueue.main.async {
            completion(result)
          }
        }
        // Nil out the completions for the current request
        self?.inProgressImageFetches[url] = nil
      }
      // Make sure we received an image
      guard (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data,
            let image = UIImage(data: data) else {
        runCompletions(withResult: .failure(NSError(domain: "No Image Returned", code: -2)))
        return
      }
      runCompletions(withResult: .success(image))
    }.resume()
  }
}
