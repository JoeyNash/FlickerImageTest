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

  /// Sets NSLayout Constraints. Automatically handles autoresizingMask
  /// - Note: Requires `self` to have a SuperView to avoid a crash
  func setAutoLayout(_ constraints: [NSLayoutConstraint]) {
    guard !(superview == nil) else {
      assertionFailure("Cannot set constraints before adding to superView")
      return
    }
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(constraints)
  }
}
