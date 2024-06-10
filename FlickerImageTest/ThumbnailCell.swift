//
//  ThumbnailCell.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/7/24.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {

  static let reuseId = "thumbnail_cell"
  static let notFound = UIImage(named: "ImageNotFound")

  private struct LayoutConstants {
    static let margin: CGFloat = 8
  }

  var imageUrl: String?

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(image: Self.notFound)
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    // Setting a shadow
    imageView.addShadow()
    return imageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.margin),
      imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.margin),
      imageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.margin),
      imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.margin)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setImage(from url: String, _ image: UIImage?) {
    if imageUrl == url, let image = image {
      // Only set image if it is for this cell. Prevent setting once cell is re-used by matching original URL.
      imageView.image = image
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageUrl = nil
    imageView.image = Self.notFound
  }

}
