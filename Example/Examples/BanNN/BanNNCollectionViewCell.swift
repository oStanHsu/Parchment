//
//  BanNNCollectionViewCell.swift
//  Example
//
//  Created by nguyen.ngoc.ban on 5/26/20.
//  Copyright © 2020 Martin Rechsteiner. All rights reserved.
//

import UIKit
import Parchment

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let fontSizeTitle: CGFloat = 24
let fontSizeSelectedTitle: CGFloat = 24

let fontSizeDes: CGFloat = 15
let fontSizeSelectedDes: CGFloat = 15

var selectedColor = hexStringToUIColor(hex: "224088") // "UIColor.black"
var color = hexStringToUIColor(hex: "8495BD")

let constant: CGFloat = 20
let selectedConstant: CGFloat = 0

class BanNNCollectionViewCell: PagingCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var centerConstraint: NSLayoutConstraint!

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
//            nameLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedTitle)
            nameLabel.textColor = selectedColor
//            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedDes)
//            descriptionLabel.textColor = selectedColor
        } else {
//            nameLabel.font = UIFont.systemFont(ofSize: fontSizeSelectedDes)
            nameLabel.textColor = color
            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeDes)
//            descriptionLabel.textColor = color
        }
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            nameLabel.textColor = UIColor.interpolate(
                from: color,
                to: selectedColor,
                with: attributes.progress)

//            let fontSizeOfName: CGFloat = (fontSizeTitle * (1 - attributes.progress) + fontSizeSelectedTitle * (attributes.progress))
//            nameLabel.font = UIFont.systemFont(ofSize: fontSizeOfName)
//
//            let fontSizeOfDes: CGFloat = (fontSizeDes * (1 - attributes.progress) + fontSizeSelectedDes * (attributes.progress))
//            descriptionLabel.font = UIFont.systemFont(ofSize: fontSizeOfDes)

            centerConstraint.constant = constant * (1-attributes.progress) + selectedConstant * attributes.progress

//            descriptionLabel.textColor = UIColor.interpolate(
//                from: color,
//                to: selectedColor,
//                with: attributes.progress)

          print("attributes.progress \(attributes.progress)")
        }
    }
}
