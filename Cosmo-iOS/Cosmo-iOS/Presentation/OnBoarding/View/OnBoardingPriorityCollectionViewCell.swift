//
//  OnBoardingPriorityCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/1/25.
//

import UIKit

//class OnBoardingPriorityCollectionViewCell: UICollectionViewCell {
//    static let identifier = "OnBoardingPriorityCollectionViewCell"
//    
//    private let iconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = .black
//        return imageView
//    }()
//    
//    private let subjectLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .black
//        return label
//    }()
//    
//    private let moreButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//        button.tintColor = .gray
//        return button
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
//    private func setupUI() {
//        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 8
//        contentView.layer.borderWidth = 1
//        contentView.layer.borderColor = UIColor.lightGray.cgColor
//        
//        contentView.addSubview(iconImageView)
//        contentView.addSubview(subjectLabel)
//        contentView.addSubview(moreButton)
//        
//        iconImageView.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(16)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(24)
//        }
//        
//        subjectLabel.snp.makeConstraints { make in
//            make.left.equalTo(iconImageView.snp.right).offset(8)
//            make.centerY.equalToSuperview()
//        }
//        
//        moreButton.snp.makeConstraints { make in
//            make.right.equalToSuperview().offset(-16)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(24)
//        }
//    }
//    
//    func configure(subject: String) {
//        subjectLabel.text = subject
//        iconImageView.image = UIImage(systemName: "book.fill")
//    }
//}

class OnBoardingPriorityCollectionViewCell: UICollectionViewCell {
    static let identifier = "OnBoardingPriorityCollectionViewCell"
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .black
            return imageView
        }()
        
        private let subjectLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = .black
            return label
        }()
        
        private let moreButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "text.justify"), for: .normal)
            button.tintColor = .gray
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
//        private func setupUI() {
//            contentView.backgroundColor = .white
//            contentView.layer.cornerRadius = 8
//            contentView.layer.borderWidth = 1
//            contentView.layer.borderColor = UIColor.lightGray.cgColor
//            
//            contentView.addSubview(iconImageView)
//            contentView.addSubview(subjectLabel)
//            contentView.addSubview(moreButton)
//            
//            iconImageView.snp.makeConstraints { make in
//                make.left.equalToSuperview().offset(16)
//                make.centerY.equalToSuperview()
//                make.width.height.equalTo(24)
//            }
//            
//            subjectLabel.snp.makeConstraints { make in
//                make.left.equalTo(iconImageView.snp.right).offset(8)
//                make.centerY.equalToSuperview()
//            }
//            
//            moreButton.snp.makeConstraints { make in
//                make.right.equalToSuperview().offset(-16)
//                make.centerY.equalToSuperview()
//                make.width.height.equalTo(24)
//            }
//        }
    private func setupUI() {
            // 셀의 배경과 테두리 설정
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 25 // 더 둥근 모서리로 타원형 느낌 강화
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.systemGray5.cgColor // 더 연한 회색 테두리
            contentView.clipsToBounds = true // 모서리 둥글게 자르기
            
            // 그림자 추가 (선택 사항)
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOpacity = 0.1
            contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            contentView.layer.shadowRadius = 4
            
            contentView.addSubview(iconImageView)
            contentView.addSubview(subjectLabel)
            contentView.addSubview(moreButton)
            
            // 아이콘 레이아웃
            iconImageView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
            }
            
            // 과목 레이블 레이아웃
            subjectLabel.snp.makeConstraints { make in
                make.left.equalTo(iconImageView.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
            
            // 드래그 핸들 레이아웃
            moreButton.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
            }
        }
        
        func configure(subject: String) {
            subjectLabel.text = subject
            iconImageView.image = UIImage(systemName: "book.fill")
        }
}
