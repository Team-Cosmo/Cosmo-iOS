//
//  OnBoardingCompetencyCollectionViewCell.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/6/25.
//

import UIKit

class OnBoardingCompetencyCollectionViewCell: UICollectionViewCell {
    static let identifier = "OnBoardingCompetencyCollectionViewCell"
    
    var onSliderValueChanged: ((Float) -> Void)? // 슬라이더 값 변경 콜백
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        if let customFont = UIFont(name: "DOSGothic", size: 16) {
            label.font = customFont
        } else {
            print("폰트 'DOSGothic'을 찾을 수 없습니다. 시스템 폰트로 대체합니다.")
            label.font = .systemFont(ofSize: 16, weight: .regular)
        }
        label.textColor = .black
        return label
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 0
        slider.minimumTrackTintColor = .black // 슬라이더 왼쪽 부분을 검은색으로 설정
        slider.maximumTrackTintColor = .lightGray // 슬라이더 오른쪽 부분은 연한 회색
        slider.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal) // 썸 아이콘
        return slider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 25
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.clipsToBounds = true
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(subjectLabel)
        contentView.addSubview(slider)
        
        // 아이콘 레이아웃
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        // 과목 레이블 레이아웃
        subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalTo(iconImageView)
            make.right.equalToSuperview().offset(-16) // 오른쪽 여백 추가
        }
        
        // 슬라이더 레이아웃
        slider.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func setupSlider() {
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged() {
        onSliderValueChanged?(slider.value)
    }
    
    func configure(subject: String) {
        subjectLabel.text = subject
        switch subject {
        case "운영체제":
            iconImageView.image = UIImage(systemName: "gearshape.fill")
        case "자료구조":
            iconImageView.image = UIImage(systemName: "chart.bar.fill")
        case "알고리즘":
            iconImageView.image = UIImage(systemName: "flowchart.fill")
        case "네트워크":
            iconImageView.image = UIImage(systemName: "network")
        case "데이터베이스":
            iconImageView.image = UIImage(systemName: "tablecells.fill")
        default:
            iconImageView.image = UIImage(systemName: "book.fill")
        }
    }
}
