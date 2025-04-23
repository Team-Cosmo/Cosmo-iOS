//
//  ResultViewController.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct QuestionResult {
    let question: String
    let answer: String
    let isCorrect: Bool
}

class ResultViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let results: [QuestionResult]
    
    private let learningFinished: Bool
    
    var completionHandler: (() -> Void)?
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 학습 완료"
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private let headerView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img_home")
        return view
    }()
    
    private let resultCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        return collectionView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    init(results: [QuestionResult], learningFinished: Bool) {
        self.results = results
        self.learningFinished = learningFinished
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bind()
        
        correctCount()
        headerView.isUserInteractionEnabled = true
    }
    
    private func setupUI() {
        view.backgroundColor = .gray200
        
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(progressLabel)
        headerView.addSubview(closeButton)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 4)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 9)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        
        view.addSubview(resultCollectionView)
        
        resultCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupCollectionView() {
        resultCollectionView.register(ResultCollectionViewCell.self, forCellWithReuseIdentifier: ResultCollectionViewCell.identifier)
    }
    
    private func bind() {
        Observable.just(results)
            .bind(to: resultCollectionView.rx.items(cellIdentifier: ResultCollectionViewCell.identifier, cellType: ResultCollectionViewCell.self)) { (row, element, cell) in
                cell.configure(with: element.question, answer: element.answer, isCorrect: element.isCorrect)
            }
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true) {
                    owner.completionHandler?()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension ResultViewController {
    private func correctCount() {
        let correctCount = results.filter { $0.isCorrect }.count
        progressLabel.text = "10문제 중\n \(correctCount)문제 명중했어요!"
        print(correctCount)
    }
}
