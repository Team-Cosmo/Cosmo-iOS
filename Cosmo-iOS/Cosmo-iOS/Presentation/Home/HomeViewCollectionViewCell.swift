//
//  HomeViewCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import UIKit
import SnapKit

class HomeViewCollectionViewCell: UICollectionViewCell {
    static let identifier = "HomeViewCollectionViewCell"
        
        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
            return imageView
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            contentView.backgroundColor = .black
            contentView.layer.cornerRadius = 10
            
            contentView.addSubview(imageView)
            contentView.addSubview(label)
            
            imageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(30)
            }
            
            label.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).inset(-20)
                make.leading.trailing.equalToSuperview()
            }
        }
        
        func configure(with title: String, image: UIImage?) {
            label.text = title
            imageView.image = image
        }
}
