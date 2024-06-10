//
//  DateFormatter+Extensions.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/10/24.
//

import Foundation

extension DateFormatter {
  static let displayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-DDThh:mm:ssZ"
    return formatter
  }()
}
