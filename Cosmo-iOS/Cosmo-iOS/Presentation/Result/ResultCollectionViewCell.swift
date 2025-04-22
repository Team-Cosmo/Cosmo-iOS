//
//  ResultCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/15/25.
//

import UIKit
import SnapKit

class ResultCollectionViewCell: UICollectionViewCell {
    static let identifier = "ResultCollectionViewCell"
    
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
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
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        contentView.addSubview(statusImageView)
        contentView.addSubview(questionLabel)
        contentView.addSubview(answerLabel)
        contentView.addSubview(favoriteButton)
        
        statusImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
        }
        
        answerLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-10)
            make.top.equalTo(questionLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
    }
    
    func configure(with question: String, answer: String, isCorrect: Bool) {
        questionLabel.text = question
        answerLabel.text = "정답: \(answer)"
        statusImageView.image = UIImage(named: isCorrect ? "img_quiz_correct" : "img_quiz_wrong")
    }
}
