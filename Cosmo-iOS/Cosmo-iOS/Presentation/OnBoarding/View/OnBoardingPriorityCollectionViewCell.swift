//
//  OnBoardingPriorityCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/1/25.
//

import UIKit

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
        label.font = UIFont(name: "Pretendard-Bold", size: 18)
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
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.clipsToBounds = true
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(moreButton)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(moreButton.snp.left).offset(-8)
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func configure(subject: String) {
        subjectLabel.text = subject
        
        switch subject {
        case "운영체제":
            iconImageView.image = UIImage(named: "img_operatingsystem")
        case "자료구조":
            iconImageView.image = UIImage(named: "img_datastructure")
        case "알고리즘":
            iconImageView.image = UIImage(named: "img_algorithm")
        case "네트워크":
            iconImageView.image = UIImage(named: "img_network")
        case "데이터베이스":
            iconImageView.image = UIImage(named: "img_database")
        default:
            iconImageView.image = UIImage(systemName: "book.fill")
        }
    }
}
