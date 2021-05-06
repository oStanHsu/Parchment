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
    DataPaging(title: "Ban", des: "66 activities"),
    DataPaging(title: "Hai", des: "3 activities"),
    DataPaging(title: "Nguyet", des: "12 activities"),
    DataPaging(title: "Ban1", des: "8 activities"),
    DataPaging(title: "Hai1", des: "12 activities"),
    DataPaging(title: "Nguyet1", des: "4 activities"),
    DataPaging(title: "Ban2", des: "3 activities"),
    DataPaging(title: "Hai2", des: "2 activities"),
    DataPaging(title: "Nguyet2", des: "1 activitie")
  ]
}

class BanNNViewController: UIViewController {

  var vcs = [ContentViewController2]()

  override func viewDidLoad() {
    super.viewDidLoad()
    for (i, data) in getDatas().enumerated() {
      let vc = ContentViewController2(index: i, data: data)
      vcs.append(vc)
    }
    let pagingViewController = PagingViewController()
    pagingViewController.menuItemSize = PagingMenuItemSize.sizeToFit(minWidth: UIScreen.main.bounds.width/3, height: 100)
    pagingViewController.register(UINib(nibName: "BanNNCollectionViewCell", bundle: nil), for: BanNNPagingItem.self)
    pagingViewController.delegate = self
    pagingViewController.menuInteraction = .swipe
    pagingViewController.indicatorColor = .clear
    pagingViewController.borderOptions = .hidden

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

final class ContentViewController2: UIViewController {

  var index: Int

  convenience init(index: Int, data: DataPaging) {
    self.init(title: "\(index)", content: "\(data.title + "\n" + data.des)")
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
    label.numberOfLines = 0
    label.sizeToFit()

    view.addSubview(label)
    view.constrainToEdges(label)
    view.backgroundColor = hexStringToUIColor(hex: "ECEEFC")
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

