//
//  HomeViewController.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: HomeViewModel
    
    private lazy var subjectSelectionObservable: Observable<String> = {
        subjectCollectionView.rx.itemSelected
            .map { [weak self] indexPath in
                self?.viewModel.getSubject(at: indexPath.item) ?? "운영체제"
            }
    }()
    
    private let progressUpdateRelay = PublishRelay<Int>()
    
    private let headerView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "img_home")
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 학습 타겟"
        label.textColor = .white
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10 완료"
        label.textColor = .white
        label.font = UIFont(name: "DOSGothic", size: 50)
        
        return label
    }()
    
    private lazy var progressCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 24, height: 24)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = false
        return collectionView
    }()
    
    private let subjectCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let subjectTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "과목별 학습하기"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let storageBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let storageLabel: UILabel = {
        let label = UILabel()
        label.text = "그레이"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
//    private let storageTitleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "내가 저장한 문제"
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
//    
//    private let questionBoxView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
//        view.layer.cornerRadius = 10
//        return view
//    }()
//    
//    private let questionLabel: UILabel = {
//        let label = UILabel()
//        label.text = "그레이"
//        label.textAlignment = .center
//        label.textColor = .gray
//        label.font = .systemFont(ofSize: 14)
//        return label
//    }()
//    
//    private let questionTitleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "남겨놓은 학습 기록"
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        return label
//    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학습하러 가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "img_btn_cta"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 22)
        return button
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(progressCollectionView)
        headerView.addSubview(progressLabel)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 3)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 9)
        }
        
        progressCollectionView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(UIScreen.main.bounds.width * 0.7) // 필요에 따라 너비 조정
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(subjectTitleLabel)
        view.addSubview(subjectCollectionView)
        
        subjectTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        subjectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(subjectTitleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(UIScreen.main.bounds.height / 8)
        }
        
        view.addSubview(storageBoxView)
//        view.addSubview(questionBoxView)
        
//        storageBoxView.addSubview(storageTitleLabel)
        storageBoxView.addSubview(storageLabel)
        
//        questionBoxView.addSubview(questionTitleLabel)
//        questionBoxView.addSubview(questionLabel)
        
        storageBoxView.snp.makeConstraints { make in
            make.top.equalTo(subjectCollectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo((view.frame.width - 50) / 2)
            make.height.equalTo(100)
        }
        
//        questionBoxView.snp.makeConstraints { make in
//            make.top.equalTo(subjectCollectionView.snp.bottom).offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.width.equalTo((view.frame.width - 50) / 2)
//            make.height.equalTo(100)
//        }
//        
//        storageTitleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.centerX.equalToSuperview()
//        }
//        
//        storageLabel.snp.makeConstraints { make in
//            make.top.equalTo(storageTitleLabel.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//        }
//        
//        questionTitleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(20)
//            make.centerX.equalToSuperview()
//        }
//        
//        questionLabel.snp.makeConstraints { make in
//            make.top.equalTo(questionTitleLabel.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//        }
        
        view.addSubview(startButton)
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func setupCollectionView() {
        subjectCollectionView.register(HomeViewCollectionViewCell.self, forCellWithReuseIdentifier: HomeViewCollectionViewCell.identifier)
        progressCollectionView.register(CrosshairCollectionViewCell.self, forCellWithReuseIdentifier: CrosshairCollectionViewCell.identifier)
        
        //        setupProgressCrosshairs(completedCount: 0)
    }
    
    private func bind() {
        let input = HomeViewModel.Input(
            fetchQuestionsTrigger: fetchQuestionsTrigger(),
            startLearningTrigger: startButton.rx.tap.asObservable(),
            updateProgressTrigger: progressUpdateRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.subjects
            .drive(subjectCollectionView.rx.items(cellIdentifier: HomeViewCollectionViewCell.identifier, cellType: HomeViewCollectionViewCell.self)) { (row, element, cell) in
                let image = UIImage(named: element.1)
                cell.configure(with: element.0, image: image)
            }
            .disposed(by: disposeBag)
        
        output.fetchedQuestions
            .drive(with: self, onNext: { owner, questions in
                if !questions.isEmpty {
                    owner.presentQuestionViewController(with: questions)
                } else {
                    print("No questions fetched, skipping navigation")
                }
            })
            .disposed(by: disposeBag)
        
        output.progress
            .drive(onNext: { [weak self] correctCount in
                self?.updateProgressView(correctCount: correctCount)
            })
            .disposed(by: disposeBag)
        
        //        QuestionViewController.
        //            .bind(with: self, onNext: { owner, value in
        //                owner.updateProgressView(correctCount: value)
        //            })
        //            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(with: self, onNext: { owner, isLoading in
                if isLoading {
                    owner.showLoadingIndicator()
                    owner.disableUI()
                } else {
                    owner.hideLoadingIndicator()
                    owner.enableUI()
                }
            })
            .disposed(by: disposeBag)
        
        output.errorMessage
            .drive(with: self, onNext: { owner, value in
                if let message = value {
                    print("Error: \(message)")
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
    private func fetchQuestionsTrigger() -> Observable<String> {
        return subjectSelectionObservable
            .do(onNext: { subject in
                print("Selected subject: \(subject)")
            })
    }
    
    private func updateProgressView(correctCount: Int) {
        let dataSource = Array(0..<10).map { $0 < correctCount }
        
        Observable.just(dataSource)
            .bind(to: progressCollectionView.rx.items(cellIdentifier: CrosshairCollectionViewCell.identifier, cellType: CrosshairCollectionViewCell.self)) { index, isFilled, cell in
                cell.configure(filled: isFilled)
            }
            .disposed(by: disposeBag)
        
        progressLabel.text = "\(correctCount)/10 완료"
    }
    
    private func showLoadingIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 999
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    private func hideLoadingIndicator() {
        view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
    }
    
    private func presentQuestionViewController(with questions: [Question]) {
        let questionRepo = QuestionRepositoryImpl(remoteDataSource: RemoteQuestionDataSourceImpl())
        let fetchQuestionsUseCase = FetchQuestionsUseCaseImpl(repository: questionRepo)
        
        let viewModel = QuestionViewModel(fetchQuestionsUseCase: fetchQuestionsUseCase)
        
        let questionViewController = QuestionViewController(viewModel: viewModel, questions: questions)
        
        questionViewController.modalPresentationStyle = .fullScreen
        self.present(questionViewController, animated: true, completion: nil)
    }
    
    private func disableUI() {
        startButton.isEnabled = false
        subjectCollectionView.isUserInteractionEnabled = false
        storageBoxView.isUserInteractionEnabled = false
//        questionBoxView.isUserInteractionEnabled = false
        print("UI Disabled")
    }
    
    private func enableUI() {
        startButton.isEnabled = true
        subjectCollectionView.isUserInteractionEnabled = true
        storageBoxView.isUserInteractionEnabled = true
//        questionBoxView.isUserInteractionEnabled = true
        print("UI Enabled")
    }
}
