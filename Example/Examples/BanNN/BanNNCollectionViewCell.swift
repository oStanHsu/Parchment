//
//  BanNNCollectionViewCell.swift
//  Example
//
//  Created by nguyen.ngoc.ban on 5/26/20.
//  Copyright © 2020 Martin Rechsteiner. All rights reserved.
//

import UIKit
import Parchment

let fontSizeTitle: CGFloat = 10
let fontSizeSelectedTitle: CGFloat = 20

let fontSizeDes: CGFloat = 6
let fontSizeSelectedDes: CGFloat = 12

var selectedColor = UIColor.black
var color = UIColor.lightGray

class BanNNCollectionViewCell: PagingCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    private var pagingItem: BanNNPagingItem!

    open override var isSelected: Bool {
        didSet {
            configureTitleLabel()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        if let pagingItem = pagingItem as? BanNNPagingItem {
            self.pagingItem = pagingItem
        }
        configureTitleLabel()
    }

    open func configureTitleLabel() {
        guard let pagingItem = pagingItem else { return }
        nameLabel.text = pagingItem.title
        descriptionLabel.text = pagingItem.des

        if isSelected {
            nameLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedTitle)
            nameLabel.textColor = selectedColor
            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedDes)
            descriptionLabel.textColor = selectedColor
        } else {
            nameLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedDes)
            nameLabel.textColor = color
            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeDes)
            descriptionLabel.textColor = color
        }
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            nameLabel.textColor = UIColor.interpolate(
                from: color,
                to: selectedColor,
                with: attributes.progress)

            let fontSizeOfName: CGFloat = (fontSizeTitle * (1 - attributes.progress) + fontSizeSelectedTitle * (attributes.progress))
            nameLabel.font = UIFont.systemFont(ofSize: fontSizeOfName)

            let fontSizeOfDes: CGFloat = (fontSizeDes * (1 - attributes.progress) + fontSizeSelectedDes * (attributes.progress))
            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeOfDes)

            descriptionLabel.textColor = UIColor.interpolate(
                from: color,
                to: selectedColor,
                with: attributes.progress)
        }
    }
}
