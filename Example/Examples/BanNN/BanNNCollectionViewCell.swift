//
//  BanNNCollectionViewCell.swift
//  Example
//
//  Created by nguyen.ngoc.ban on 5/26/20.
//  Copyright © 2020 Martin Rechsteiner. All rights reserved.
//

import UIKit
import Parchment

class BanNNCollectionViewCell: PagingCell {

    @IBOutlet private weak var nameLabel: UILabel!

    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        print("setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) ")
        nameLabel.text = cities[(pagingItem as? BanNNPagingItem)?.index ?? 0]
        if selected {
            backgroundColor = UIColor.blue
            nameLabel.textColor = UIColor.white
        } else {
            backgroundColor = UIColor.white
            nameLabel.textColor = UIColor.black
        }
    }
}
