//
//  HomeViewCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import UIKit
import SnapKit

//class HomeViewCollectionViewCell: UICollectionViewCell {
//    static let identifier = "HomeViewCollectionViewCell"
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = .white
//        return imageView
//    }()
//    
//    private let label: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 12)
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    //        private func setupUI() {
//    //            contentView.backgroundColor = .black
//    //            contentView.layer.cornerRadius = 10
//    //
//    //            contentView.addSubview(imageView)
//    //            contentView.addSubview(label)
//    //
//    //            imageView.snp.makeConstraints { make in
//    //                make.center.equalToSuperview()
//    //                make.width.height.equalTo(30)
//    //            }
//    //
//    //            label.snp.makeConstraints { make in
//    //                make.top.equalTo(imageView.snp.bottom).inset(-20)
//    //                make.leading.trailing.equalToSuperview()
//    //            }
//    //        }
//    
//    
//    private func setupUI() {
//        contentView.backgroundColor = .systemGray6 // 이미지처럼 밝은 회색 배경
//        contentView.layer.cornerRadius = 10
//        
//        contentView.addSubview(imageView)
//        contentView.addSubview(label)
//        
//        imageView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-10) // 상단으로 약간 이동
//            make.width.height.equalTo(40) // 이미지 크기 키우기
//        }
//        
//        label.snp.makeConstraints { make in
//            make.top.equalTo(imageView.snp.bottom).offset(5)
//            make.leading.trailing.equalToSuperview()
//        }
//    }
//    
//    func configure(with title: String, image: UIImage?) {
//        label.text = title
//        imageView.image = image
//    }
//}


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
        contentView.backgroundColor = .systemGray6 // 이미지처럼 밝은 회색 배경
        contentView.layer.cornerRadius = 10
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10) // 상단으로 약간 이동
            make.width.height.equalTo(40) // 이미지 크기 키우기
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(with title: String, image: UIImage?) {
        label.text = title
        imageView.image = image
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
            label.textColor = .white
            imageView.tintColor = .white
        } else {
            contentView.backgroundColor = .systemGray6
            label.textColor = .black
            imageView.tintColor = .black
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected(false)
    }
}
