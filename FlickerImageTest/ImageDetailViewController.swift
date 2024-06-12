//
//  ImageDetailViewController.swift
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/10/24.
//

import UIKit

class ImageDetailViewController: UIViewController {

  private struct LayoutConstants {
    static let margin: CGFloat = 20
    static let padding: CGFloat = 12
  }

  let imageInfo: FlickrItem
  let flickrService: FlickerService

  let scrollView = UIScrollView(frame: .zero)

  lazy var imageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "ImageNotFound"))
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = imageInfo.title
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()

  lazy var dateTakenLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "Date Taken: \(DateFormatter.displayFormatter.string(from: imageInfo.dateTaken))"
    return label
  }()

  lazy var authorLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "Author: \(imageInfo.author)"
    label.numberOfLines = 0
    return label
  }()

  lazy var tagLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "Tags: \(imageInfo.tags.replacingOccurrences(of: " ", with: ", "))"
    label.numberOfLines = 0
    return label
  }()

  lazy var imageSizeLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "Height: 0 px, Width: 0 px"
    label.textAlignment = .center
    return label
  }()

  lazy var detailStack: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [authorLabel, dateTakenLabel, tagLabel])
    stackView.axis = .vertical
    stackView.spacing = LayoutConstants.padding
    return stackView
  }()

  init(withImage imageInfo: FlickrItem, andServiceProvider serviceProvider: FlickerService) {
    self.imageInfo = imageInfo
    self.flickrService = serviceProvider
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor(red: 1, green: 253/255, blue: 208/255, alpha: 1)
    // Set up scrollView
    view.addSubview(scrollView)
    scrollView.setAutoLayout([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.margin),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.margin),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.margin),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.margin)
    ])
    let scrollingContentView = UIView(frame: .zero)
    scrollView.addSubview(scrollingContentView)
    scrollingContentView.setAutoLayout([
      scrollingContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      scrollingContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      scrollingContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      scrollingContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      scrollingContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
    ])
    // Set up title
    scrollingContentView.addSubview(titleLabel)
    titleLabel.setAutoLayout([
      titleLabel.topAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.topAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.trailingAnchor)
    ])
    // Set up image
    scrollingContentView.addSubview(imageView)
    imageView.setAutoLayout([
      imageView.centerXAnchor.constraint(equalTo: scrollingContentView.centerXAnchor),
      imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutConstants.padding),
      imageView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollingContentView.safeAreaLayoutGuide.leadingAnchor),
      imageView.trailingAnchor.constraint(lessThanOrEqualTo: scrollingContentView.safeAreaLayoutGuide.trailingAnchor)
    ])
    // Set up size label
    scrollingContentView.addSubview(imageSizeLabel)
    imageSizeLabel.setAutoLayout([
      imageSizeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: LayoutConstants.padding),
      imageSizeLabel.leadingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.leadingAnchor),
      imageSizeLabel.trailingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.trailingAnchor)
    ])
    //Set up stack view of other details
    scrollingContentView.addSubview(detailStack)
    detailStack.setAutoLayout([
      detailStack.topAnchor.constraint(equalTo: imageSizeLabel.bottomAnchor, constant: LayoutConstants.padding),
      detailStack.leadingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.leadingAnchor),
      detailStack.trailingAnchor.constraint(equalTo: scrollingContentView.safeAreaLayoutGuide.trailingAnchor),
      detailStack.bottomAnchor.constraint(equalTo: scrollingContentView.bottomAnchor)
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Task { @MainActor in
      do {
        let image = try await flickrService.fetchImage(forURL: imageInfo.media.imageURL)
        self.imageView.image = image
        self.imageSizeLabel.text = "Height: \(image.size.height * image.scale) px, Width: \(image.size.width * image.scale) px"
      } catch let error {
        print(String(describing: error))
      }
    }
  }
}
