//
//  String+Extensions.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import Foundation

extension String {

  /// This function parses a String and looks for an integer value based on a key.
  /// Example: width=140 would return 140.
  /// width="140" would also return 140
  /// Returns nil if the key or value cannot be found
  func getIntValue(forKey key: String) -> Int? {
    guard self.contains(key) else {
      return nil
    }
    // TODO: Implement real code
    return nil
  }
}
