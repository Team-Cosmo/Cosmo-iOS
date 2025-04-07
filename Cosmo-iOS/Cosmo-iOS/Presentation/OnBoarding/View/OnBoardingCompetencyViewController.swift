//
//  OnBoardingCompetencyViewController.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OnBoardingCompetencyViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "과목별 역량을 알려주세요"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "작우 데이터를 통해 수치를 조정할 수 있어요"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let beginnerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("처음 배워요", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let expertButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선명한 수 있어요!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnBoardingCompetencyCollectionViewCell.self, forCellWithReuseIdentifier: OnBoardingCompetencyCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let subjects = BehaviorRelay<[String]>(value: [
        "운영체제",
        "자료구조",
        "알고리즘",
        "네트워크",
        "데이터베이스"
    ])
    
    private var sliderValues: [String: Float] = [:] // 과목별 슬라이더 값 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(beginnerButton)
        view.addSubview(expertButton)
        view.addSubview(collectionView)
        view.addSubview(completeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        beginnerButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        expertButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(beginnerButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(completeButton.snp.top).offset(-20)
        }
        
        completeButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func bind() {
        subjects
            .bind(to: collectionView.rx.items(cellIdentifier: OnBoardingCompetencyCollectionViewCell.identifier, cellType: OnBoardingCompetencyCollectionViewCell.self)) { [weak self] (row, element, cell) in
                cell.configure(subject: element)
                // 슬라이더 값 변경 이벤트 바인딩
                cell.onSliderValueChanged = { value in
                    self?.sliderValues[element] = value
                    print("\(element) 슬라이더 값: \(value)")
                }
            }
            .disposed(by: disposeBag)
        
        beginnerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("처음 배워요 버튼이 눌렸습니다.")
                // 모든 슬라이더 값을 0으로 설정
                self?.collectionView.visibleCells.forEach { cell in
                    if let priorityCell = cell as? OnBoardingCompetencyCollectionViewCell {
                        priorityCell.slider.value = 0
                    }
                }
                self?.subjects.value.forEach { subject in
                    self?.sliderValues[subject] = 0
                }
            })
            .disposed(by: disposeBag)
        
        expertButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("선명한 수 있어요! 버튼이 눌렸습니다.")
                // 모든 슬라이더 값을 100으로 설정
                self?.collectionView.visibleCells.forEach { cell in
                    if let priorityCell = cell as? OnBoardingCompetencyCollectionViewCell {
                        priorityCell.slider.value = 100
                    }
                }
                self?.subjects.value.forEach { subject in
                    self?.sliderValues[subject] = 100
                }
            })
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                print("완료하기 버튼이 눌렸습니다.")
                print("최종 슬라이더 값: \(self?.sliderValues ?? [:])")
            })
            .disposed(by: disposeBag)
    }
    
}
