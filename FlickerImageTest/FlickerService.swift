//
//  FlickerService.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import UIKit
import Combine

protocol FlickerService: AnyObject {
  func getItemsBySearching(forTags tagList: String) -> AnyPublisher<FlickrResponse, Error>
  func fetchImage(forURL url: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void)
}

class RealFlickerService: FlickerService {

  private static var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  var imageCache: [String: UIImage] = [:]
  var inProgressImageFetches: [String: [(Result<UIImage, Error>) -> Void]] = [:]
  let searchURL = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags="

  func getItemsBySearching(forTags tagList: String) ->AnyPublisher<FlickrResponse, Error> {
    guard let requestURL = URL(string: searchURL+tagList) else {
      return Fail(error: NSError(domain: "Bad URL", code: -1))
        .eraseToAnyPublisher()
    }

    let request = URLRequest(url: requestURL)
    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { result in
        guard (result.response as? HTTPURLResponse)?.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        return result.data
      }
      .decode(type: FlickrResponse.self, decoder: Self.decoder)
      .eraseToAnyPublisher()
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
        DispatchQueue.main.async {
          for completion in self?.inProgressImageFetches[url] ?? [] {
            completion(result)
          }
          // Nil out the completions for the current request
          self?.inProgressImageFetches[url] = nil
        }
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
