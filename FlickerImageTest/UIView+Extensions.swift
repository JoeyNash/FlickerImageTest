//
//  UIView+Extensions.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/10/24.
//

import UIKit

extension UIView {
  func addShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = .zero
    layer.shadowOpacity = 0.2
    layer.shadowRadius = 4
  }
}
