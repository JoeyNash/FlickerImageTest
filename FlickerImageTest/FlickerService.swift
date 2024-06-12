//
//  FlickerService.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import UIKit

private enum LoadStatus {
  case inProgress(Task<UIImage, Error>)
  case success(UIImage)
}

protocol FlickerService: AnyObject {
  func getItemsBySearching(forTags tagList: String) async throws -> FlickrResponse
  func fetchImage(forURL url: String) async throws -> UIImage
}

class RealFlickerService: FlickerService {

  private static var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  fileprivate var requestCache: [String: LoadStatus] = [:]
  let searchURL = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags="

  func getItemsBySearching(forTags tagList: String) async throws -> FlickrResponse {
    guard let requestURL = URL(string: searchURL+tagList) else {
      throw(NSError(domain: "Bad URL", code: -1))
    }

    let request = URLRequest(url: requestURL)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200,
          let flickrResponse = try? Self.decoder.decode(FlickrResponse.self, from: data) else {
      throw(NSError(domain: "Invalid Response", code: -3))
    }
    return flickrResponse
  }
  
  func fetchImage(forURL url: String) async throws -> UIImage {
    // Check if we already have the image, or an in-progress request.
    if let status = requestCache[url] {
      switch status {
        case .success(let image):
          // Image already fetched. Return it
          return image
        case .inProgress(let task):
          // Task in progress. Either return successful image or throw error
          return try await task.value
      }
    }

    // Build and run the request
    guard let requestURL = URL(string: url) else {
      throw(NSError(domain: "Bad URL", code: -1))
    }
    let request = URLRequest(url: requestURL)
    // Create task to store. Will cache task to prevent duplicate requests
    let task: Task<UIImage, Error> = Task {
      let (data, response) = try await URLSession.shared.data(for: request)
      guard (response as? HTTPURLResponse)?.statusCode == 200,
            let image = UIImage(data: data) else {
        throw(NSError(domain: "Invalid Response", code: -3))
      }
      return image
    }
    // Set request cache so future requests to same image will wait on it with above code
    requestCache[url] = .inProgress(task)
    let image = try await task.value
    // if success, set cache to return image right away
    requestCache[url] = .success(image)
    return image
  }
}
