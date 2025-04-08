//
//  QuestionCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    static let identifier = "QuestionCollectionViewCell"
        
        private let choiceLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = .center
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
            contentView.backgroundColor = .white
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            contentView.layer.cornerRadius = 8
            
            contentView.addSubview(choiceLabel)
            choiceLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(10)
            }
        }
        
        func configure(with choice: String, isSelected: Bool) {
            choiceLabel.text = choice
            contentView.backgroundColor = isSelected ? .systemBlue.withAlphaComponent(0.1) : .white
            choiceLabel.textColor = isSelected ? .systemBlue : .black
        }
}
