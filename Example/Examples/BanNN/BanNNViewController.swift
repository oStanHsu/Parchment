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

class BanNNViewController: UIViewController {

  var vcs = [ContentViewController2]()
  var pagingItems = [BanNNPagingItem]()
  let pagingViewController = PagingViewController()

  var currentPagingItem: BanNNPagingItem!

  var originDatas = [
    DataPaging(title: "Ban", des: "66 activities"),
    DataPaging(title: "Hai", des: "3 activities"),
//    DataPaging(title: "Nguyet", des: "12 activities"),
//    DataPaging(title: "Ban1", des: "8 activities"),
//    DataPaging(title: "Hai1", des: "12 activities"),
//    DataPaging(title: "Nguyet1", des: "4 activities"),
//    DataPaging(title: "Ban2", des: "3 activities"),
//    DataPaging(title: "Hai2", des: "2 activities"),
//    DataPaging(title: "Nguyet2", des: "1 activitie")
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    var dataMenus = originDatas
    if dataMenus.count == 1 {
      // hien thi 1 tab
    } else if dataMenus.count == 2 {
      dataMenus = dataMenus + dataMenus + dataMenus
    } else {
      dataMenus = dataMenus + dataMenus
    }

    for (index, item) in dataMenus.enumerated() {
      pagingItems.append(BanNNPagingItem(index: index, title: item.title, des: item.des))
    }

    var initedVCs = [ContentViewController2]()
    var displayVCs = [ContentViewController2]()
    for data in dataMenus {
      if originDatas.count != 2, let initedVC = initedVCs.first(where: { $0.data.title == data.title }) {
        displayVCs.append(initedVC)
      } else {
        let newVC = ContentViewController2(data: data)
        initedVCs.append(newVC)
        displayVCs.append(newVC)
      }
    }

    self.vcs = displayVCs

    guard displayVCs.count > 0 else { return }

    let width: CGFloat = displayVCs.count == 1 ? UIScreen.main.bounds.width : UIScreen.main.bounds.width/3
    pagingViewController.menuItemSize = PagingMenuItemSize.sizeToFit(minWidth: width, height: 100)
    pagingViewController.register(UINib(nibName: "BanNNCollectionViewCell", bundle: nil), for: BanNNPagingItem.self)
    pagingViewController.delegate = self
    pagingViewController.menuInteraction = .none
    pagingViewController.indicatorColor = .clear
    pagingViewController.borderOptions = .hidden

    let panGes = UIPanGestureRecognizer(target: self, action: #selector(handPanGes(_:)))
    pagingViewController.collectionView.addGestureRecognizer(panGes)

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
    let item = getPagingItem(index: 0)
    pagingViewController.select(pagingItem: getPagingItem(index: 0))
    self.currentPagingItem = item
  }

  func getPagingItem(index: Int) -> BanNNPagingItem {
    var item = pagingItems[index]
    item.checkMaxIndex = pagingItems.count - 1
    return item
  }

    var beginGesturePoint: CGPoint?
    var beginContentOffset: CGFloat?
    var currentProgress: CGFloat?
    var nextPagingItem: BanNNPagingItem?

    @objc func handPanGes(_ ges: UIPanGestureRecognizer) {
      if ges.state == .began {
        self.beginGesturePoint = ges.location(in: self.view)
        self.beginContentOffset = pagingViewController.pageViewController.contentOffset
        pagingViewController.pageViewController.scrollViewWillBeginDragging(pagingViewController.pageViewController.scrollView)
      } else if ges.state == .changed {
        let currentPoint = ges.location(in: self.view)
        if let beginPoint = self.beginGesturePoint {
          let progress = (beginPoint.x - currentPoint.x)/UIScreen.main.bounds.width
          if let begin = beginContentOffset {
            pagingViewController.pageViewController.contentOffset = begin + progress * UIScreen.main.bounds.width
            pagingViewController.pageViewController.scrollViewDidScroll(pagingViewController.pageViewController.scrollView)
          }

          self.currentProgress = progress

          if progress > 0 {
            nextPagingItem = self.pagingViewController(pagingViewController, itemBefore: currentPagingItem) as? BanNNPagingItem
          } else {
            nextPagingItem = self.pagingViewController(pagingViewController, itemAfter: currentPagingItem) as? BanNNPagingItem
          }
        }
      } else if ges.state == .ended, let begin = beginContentOffset  {
        if let progress = self.currentProgress, abs(progress) >= 0.5 {
            let offset = progress >= 0.5 ? begin + UIScreen.main.bounds.width : begin - UIScreen.main.bounds.width
            pagingViewController.pageViewController.setContentOffset(offset, animated: true)
        } else {
            pagingViewController.pageViewController.setContentOffset(begin, animated: true)
        }
        pagingViewController.pageViewController.willEndDragging()
      }
    }
}

extension BanNNViewController: PagingViewControllerDelegate {
  func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
    if transitionSuccessful, let pagingItem = pagingItem as? BanNNPagingItem {
      self.currentPagingItem = pagingItem
    }
  }
}

extension BanNNViewController: PagingViewControllerInfiniteDataSource {
  func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! BanNNPagingItem
    var index = item.index + 1
    if item.index == vcs.count - 1 {
      if vcs.count <= 3 {
        return nil
      }
      index = 0
    }
    return getPagingItem(index: index)
  }

  func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! BanNNPagingItem
    var index = item.index - 1
    if item.index == 0 {
      if vcs.count <= 3 {
        return nil
      }
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

  var data: DataPaging

  init(data: DataPaging) {
    self.data = data
    super.init(nibName: nil, bundle: nil)
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
    label.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    label.textAlignment = .center
    label.text = "\(data.title + "\n" + data.des)"
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

