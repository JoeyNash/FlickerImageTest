//
//  ImageListViewController
//  FlickerImageTest
//
//  Created by Joseph Nash on 6/6/24.
//

import UIKit

class ImageListViewController: UIViewController {

  private struct LayoutConstants {
    static let margin: CGFloat = 20
    static let padding: CGFloat = 12
    static let interItemSpacing: CGFloat = 8
  }

  lazy var searchBox: UITextField = {
    let textField = UITextField(frame: .zero)
    textField.placeholder = "Enter Tags Here"
    textField.delegate = self
    textField.backgroundColor = .white
    textField.addShadow()
    return textField
  }()

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.reuseId)
    collectionView.backgroundColor = .clear
    return collectionView
  }()

  var flickerService: FlickerService = RealFlickerService()
  var items: [FlickrItem] = []

  override func loadView() {
    super.loadView()
    view.backgroundColor = UIColor(red: 1, green: 253/255, blue: 208/255, alpha: 1)
    // Setup Search
    view.addSubview(searchBox)
    searchBox.setAutoLayout([
      searchBox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.margin),
      searchBox.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.margin),
      searchBox.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.margin)
    ])
    // Setup CollectionView
    view.addSubview(collectionView)
    collectionView.setAutoLayout([
      collectionView.topAnchor.constraint(equalTo: searchBox.bottomAnchor, constant: LayoutConstants.padding),
      collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.margin),
      collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.margin),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.margin)
    ])
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Setup Layout. Done here because we are using the frame to calculate size
    (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = LayoutConstants.interItemSpacing
    (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = LayoutConstants.interItemSpacing
    let doubledSpacing = 2 * LayoutConstants.interItemSpacing
    (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(
      width: (collectionView.frame.width / 3) - doubledSpacing,
      height: collectionView.frame.height / 3 - doubledSpacing
    )
  }

  @MainActor
  func getItems(forTags tags: String) {
    Task {
      do {
        items = try await flickerService.getItemsBySearching(forTags: tags).items
        collectionView.reloadData()
      } catch let error {
        print(String(describing: error))
      }
    }
  }
}

extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    items.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let thumbnailCell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.reuseId, for: indexPath) as? ThumbnailCell else {
      return UICollectionViewCell()
    }
    let imageUrl = items[indexPath.row].media.imageURL
    thumbnailCell.imageUrl = imageUrl
    Task { @MainActor [weak thumbnailCell] in
      do {
        thumbnailCell?.setImage(from: imageUrl, try await flickerService.fetchImage(forURL: imageUrl))
      } catch let error {
        print(String(describing: error))
      }
    }
    return thumbnailCell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let detailVC = ImageDetailViewController(withImage: item, andServiceProvider: flickerService)
    detailVC.title = item.title
    self.navigationController?.pushViewController(detailVC, animated: true)
  }
}

extension ImageListViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    guard let text = textField.text?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
      return
    }
    getItems(forTags: text)
  }
}

