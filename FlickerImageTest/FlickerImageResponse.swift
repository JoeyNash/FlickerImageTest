//
//  FlickerImageResponse.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import Foundation

struct FlickrResponse: Codable {
  let items: [FlickrItem]
}

struct FlickrItem: Codable {
  let title: String
  let media: FlickrMedia
  let dateTaken: Date
  let author: String
  let tags: String
  private enum CodingKeys: String, CodingKey {
    case title, media, author, tags
    case dateTaken = "date_taken"
  }
}

struct FlickrMedia: Codable {
  let imageURL: String
  private enum CodingKeys: String, CodingKey {
    case imageURL = "m"
  }
}
