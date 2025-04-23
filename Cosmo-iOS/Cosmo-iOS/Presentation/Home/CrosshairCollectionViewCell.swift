//
//  CrosshairCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/13/25.
//

import UIKit

class CrosshairCollectionViewCell: UICollectionViewCell {
    static let identifier = "CrosshairCollectionViewCell"
       
       private let imageView: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           return imageView
       }()
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           
           contentView.addSubview(imageView)
           imageView.snp.makeConstraints { make in
               make.edges.equalToSuperview()
           }
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       func configure(filled: Bool) {
           imageView.image = filled ?
               UIImage(named: "img_crosshair_filled") :
               UIImage(named: "img_crosshair_empty")
           
           imageView.image = UIImage(named: "img_crosshair_empty")
           imageView.tintColor = filled ? UIColor.customRed : UIColor.customBlue
       }
}
