//
//  BanNNViewController.swift
//  Example
//
//  Created by nguyen.ngoc.ban on 5/26/20.
//  Copyright © 2020 Martin Rechsteiner. All rights reserved.
//

import Parchment
import UIKit

struct BanNNPagingItem: PagingItem, Hashable, Comparable {
  let index: Int
  let title: String
  let des: String

  var checkMaxIndex: Int?

  init(index: Int, title: String, des: String) {
    self.index = index
    self.title = title
    self.des = des
  }

  static func < (lhs: BanNNPagingItem, rhs: BanNNPagingItem) -> Bool {
    return lhs.index < rhs.index
  }

  func isEqual(to item: PagingItem) -> Bool {
    return (item as! BanNNPagingItem).index == index
  }

  func isBefore(item: PagingItem) -> Bool {
    guard let otherItem = item as? BanNNPagingItem else { return true }
    if let checkMaxIndex = checkMaxIndex {
      if self.index == 0 && otherItem.index == checkMaxIndex {
        return false
      } else if self.index == checkMaxIndex && otherItem.index == 0 {
        return true
      }
    }
    return self.index < otherItem.index
  }
}

struct DataPaging {
  var title: String
  var des: String
}


func getDatas() -> [DataPaging] {
  return [
    DataPaging(title: "Ban", des: "Hello"),
    DataPaging(title: "Hai", des: "12313"),
    DataPaging(title: "Nguyet", des: "4"),
    DataPaging(title: "Ban1", des: "Hello"),
    DataPaging(title: "Hai1", des: "5"),
    DataPaging(title: "Nguyet1", des: "4"),
    DataPaging(title: "Ban2", des: "3"),
    DataPaging(title: "Hai2", des: "2"),
    DataPaging(title: "Nguyet2", des: "1")
  ]
}

class BanNNViewController: UIViewController {

  var vcs = [ContentViewController2]()

  override func viewDidLoad() {
    super.viewDidLoad()
    for (i, _) in getDatas().enumerated() {
      let vc = ContentViewController2(index: i)
      vcs.append(vc)
    }
    let pagingViewController = PagingViewController()
    pagingViewController.menuItemSize = PagingMenuItemSize.sizeToFit(minWidth: 100, height: 60)
    pagingViewController.register(UINib(nibName: "BanNNCollectionViewCell", bundle: nil), for: BanNNPagingItem.self)
    pagingViewController.sizeDelegate = self
    pagingViewController.delegate = self

    // Make sure you add the PagingViewController as a child view
    // controller and constrain it to the edges of the view.
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    // Do any additional setup after loading the view.

    // Set our custom data source
    pagingViewController.infiniteDataSource = self

    // Set the current date as the selected paging item
    pagingViewController.select(pagingItem: getPagingItem(index: 0))
  }

  func getPagingItem(index: Int) -> BanNNPagingItem {
    let data = getDatas()[index]
    var item = BanNNPagingItem(index: index, title: data.title, des: data.des)
    item.checkMaxIndex = vcs.count - 1
    return item
  }
}

extension BanNNViewController: PagingViewControllerDelegate {
  func pagingViewController(_ pagingViewController: PagingViewController,
                            didScrollToItem pagingItem: PagingItem,
                            startingViewController: UIViewController?,
                            destinationViewController: UIViewController,
                            transitionSuccessful: Bool) {
    if let vc = destinationViewController as? ContentViewController2, transitionSuccessful {
      let index = vc.index
      let newItem = getPagingItem(index: index)
      pagingViewController.select(pagingItem: newItem, animated: true)
    }
  }
}

extension BanNNViewController: PagingViewControllerInfiniteDataSource {
  func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! BanNNPagingItem
    var index = item.index + 1
    if item.index == vcs.count - 1 {
      index = 0
    }
    return getPagingItem(index: index)
  }

  func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! BanNNPagingItem
    var index = item.index - 1
    if item.index == 0 {
      index = vcs.count - 1
    }
    return getPagingItem(index: index)
  }

  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    let item = pagingItem as! BanNNPagingItem
    return vcs[item.index]
  }
}

extension BanNNViewController: PagingViewControllerSizeDelegate {

  // We want the size of our paging items to equal the width of the
  // city title. Parchment does not support self-sizing cells at
  // the moment, so we have to handle the calculation ourself. We
  // can access the title string by casting the paging item to a
  // PagingTitleItem, which is the PagingItem type used by
  // FixedPagingViewController.
  func pagingViewController(_ pagingViewController: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {
    guard let item = pagingItem as? BanNNPagingItem else { return 0 }
    let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.options.menuItemSize.height)
    let attributes = [NSAttributedString.Key.font: pagingViewController.options.font]
    let rect = item.title.boundingRect(with: size,
                                       options: .usesLineFragmentOrigin,
                                       attributes: attributes,
                                       context: nil)
    let width = ceil(rect.width) + insets.left + insets.right
    return width + 20
  }

}


final class ContentViewController2: UIViewController {

  var index: Int

  convenience init(index: Int) {
    self.init(title: "\(index)", content: "\(index)")
  }

  convenience init(title: String) {
    self.init(title: title, content: title)
  }

  init(title: String, content: String) {
    self.index = Int(title) ?? Int.max
    super.init(nibName: nil, bundle: nil)
    self.title = title

    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
    label.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    label.textAlignment = .center
    label.text = content
    label.sizeToFit()

    view.addSubview(label)
    view.constrainToEdges(label)

    if index % 2 == 0 {
      view.backgroundColor = .white
    } else {
      view.backgroundColor = .red
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

