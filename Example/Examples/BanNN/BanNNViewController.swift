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

    init(index: Int) {
      self.index = index
    }

    static func < (lhs: BanNNPagingItem, rhs: BanNNPagingItem) -> Bool {
      return lhs.index < rhs.index
    }
}


let cities = [
  "Oslo",
  "Stockholm",
  "Tokyo",
  "Barcelona",
  "Vancouver",
  "Berlin",
  "Shanghai",
  "London",
  "Paris",
  "Chicago",
  "Madrid",
  "Munich",
  "Toronto",
  "Sydney",
  "Melbourne"
]

class BanNNViewController: UIViewController {

    var vcs = [ContentViewController2]()

    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...9 {
            let vc = ContentViewController2(index: i)
            vcs.append(vc)
        }
        let pagingViewController = PagingViewController()
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
        pagingViewController.select(pagingItem: BanNNPagingItem(index: 0))

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            pagingViewController.select(pagingItem: BanNNPagingItem(index: 9))
//        }

//        pagingViewController.setPagingMenuDataSource(dataSource: self)
    }

}
//
//extension BanNNViewController: PagingMenuDataSource {
//    func pagingItemBefore(pagingItem: PagingItem) -> PagingItem? {
//        let pagingItem = pagingItem as! BanNNPagingItem
//        if
//    }
//
//    func pagingItemAfter(pagingItem: PagingItem) -> PagingItem? {
//
//    }
//}

extension BanNNViewController: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController,
            didScrollToItem pagingItem: PagingItem,
            startingViewController: UIViewController?,
            destinationViewController: UIViewController,
            transitionSuccessful: Bool) {
        print("didScrollToItem startingViewController \((startingViewController as? ContentViewController2)?.index). destinationViewController \((destinationViewController as? ContentViewController2)?.index)")
        if let vc = destinationViewController as? ContentViewController2, transitionSuccessful {
            let index = vc.index
            let newItem = BanNNPagingItem(index: index)
            print("select index \(index)")
            pagingViewController.select(pagingItem: newItem, animated: true)
        }
    }
}

extension BanNNViewController: PagingViewControllerInfiniteDataSource {

    func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
        let pagingItem = pagingItem as! BanNNPagingItem
        let vc = vcs[pagingItem.index]
        return vc
    }

    func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem? {
        let pagingItem = pagingItem as! BanNNPagingItem
        if isGenerateLayout {
            if pagingItem.index > 0 {
                return BanNNPagingItem(index: pagingItem.index - 1)
            } else {
                return nil
            }
        } else {
            let beforeIndex = pagingItem.index > 0 ? pagingItem.index - 1 : vcs.count - 1
            let beforeItem = BanNNPagingItem(index: beforeIndex)
            return beforeItem
        }
    }

    func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem? {
        let pagingItem = pagingItem as! BanNNPagingItem
        if isGenerateLayout {
            if pagingItem.index < vcs.count - 1 {
                return BanNNPagingItem(index: pagingItem.index + 1)
            } else {
                return nil
            }
        } else {
            let afterIndex = pagingItem.index < vcs.count - 1 ? pagingItem.index + 1 : 0
            let afterItem = BanNNPagingItem(index: afterIndex)
            return afterItem
        }
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerBefore pagingItem: PagingItem) -> UIViewController? {
      let pagingItem = pagingItem as! BanNNPagingItem
      let beforeIndex = pagingItem.index > 0 ? pagingItem.index - 1 : vcs.count - 1
      let beforeItem = BanNNPagingItem(index: beforeIndex)
      return self.pagingViewController(pagingViewController, viewControllerFor: beforeItem)
    }

    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAfter pagingItem: PagingItem) -> UIViewController? {
      let pagingItem = pagingItem as! BanNNPagingItem
      let afterIndex = pagingItem.index < vcs.count - 1 ? pagingItem.index + 1 : 0
      let afterItem = BanNNPagingItem(index: afterIndex)
      return self.pagingViewController(pagingViewController, viewControllerFor: afterItem)
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
    let title = cities[(pagingItem as? BanNNPagingItem)?.index ?? 0]
    let rect = title.boundingRect(with: size,
                                       options: .usesLineFragmentOrigin,
                                       attributes: attributes,
                                       context: nil)

    let width = ceil(rect.width) + insets.left + insets.right

    return width
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
