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
           label.textAlignment = .left
           return label
       }()
       
       private let statusImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.isHidden = true
           return imageView
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
           contentView.addSubview(statusImageView)
           
           choiceLabel.snp.makeConstraints { make in
               make.leading.top.bottom.equalToSuperview().inset(10)
               make.trailing.equalTo(statusImageView.snp.leading).offset(-10)
           }
           
           statusImageView.snp.makeConstraints { make in
               make.centerY.equalToSuperview()
               make.trailing.equalToSuperview().inset(10)
               make.width.height.equalTo(20)
           }
       }
       
       func configure(with choice: String, isSelected: Bool, answerState: AnswerState = .none) {
           choiceLabel.text = choice
           
           switch answerState {
           case .none:
               contentView.backgroundColor = isSelected ? .black : .white
               choiceLabel.textColor = isSelected ? .white : .black
               
               if isSelected {
                   statusImageView.image = UIImage(named: "img_quiz_select")
                   statusImageView.isHidden = false
               } else {
                   statusImageView.isHidden = true
               }
               
           case .correct:
               contentView.backgroundColor = .black
               choiceLabel.textColor = .white
               statusImageView.image = UIImage(named: "img_quiz_correct")
               statusImageView.isHidden = false
               
           case .wrong:
               contentView.backgroundColor = .black
               choiceLabel.textColor = .white
               statusImageView.image = UIImage(named: "img_quiz_wrong")
               statusImageView.isHidden = false
           }
       }
}

enum AnswerState {
    case none    // 기본 상태
    case correct // 정답
    case wrong   // 오답
}
