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
    
    private let subjectSelectedRelay = PublishRelay<Int>()
    private let fetchQuestionsRelay = PublishRelay<Void>()
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
        label.text = "\(UserDefaultsManager.shared.count)번 완료!"
        label.textColor = .white
        label.font = UIFont(name: "DOSGothic", size: 40)
        
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
        layout.scrollDirection = .vertical
        
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
   
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 20
        let availableWidth = screenWidth - (padding * 2) - (10 * 2)
        let cellWidth = availableWidth / 3
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let subjectTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "과목별 학습하기"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let storageLabel: UILabel = {
        let label = UILabel()
        label.text = "그레이"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학습하러 가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "img_btn_cta"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 22)
        button.isEnabled = false
        button.alpha = 0.5
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
        view.backgroundColor = .gray200
        
        view.addSubview(headerView)
        headerView.addSubview(headerLabel)
        headerView.addSubview(progressCollectionView)
        headerView.addSubview(progressLabel)
        
        view.addSubview(subjectTitleLabel)
        view.addSubview(subjectCollectionView)
        view.addSubview(startButton)
        
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
            make.width.equalTo(UIScreen.main.bounds.width * 0.7)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(20)
        }
        
        subjectTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        subjectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(subjectTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(((UIScreen.main.bounds.width - 50) / 2) * 3 + 20)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func setupCollectionView() {
        subjectCollectionView.register(HomeViewCollectionViewCell.self, forCellWithReuseIdentifier: HomeViewCollectionViewCell.identifier)
        progressCollectionView.register(CrosshairCollectionViewCell.self, forCellWithReuseIdentifier: CrosshairCollectionViewCell.identifier)
    }
    
    private func bind() {
        let input = HomeViewModel.Input(
            fetchQuestionsTrigger: fetchQuestionsRelay.asObservable(),
            selectSubjectTrigger: subjectCollectionView.rx.itemSelected.map { $0.item },
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
        
        output.selectedSubject
            .drive(onNext: { [weak self] subject in
                guard let self = self else { return }
                if let subject = subject {
                    self.startButton.setTitle("\(subject) 학습하러 가기", for: .normal)
                    self.startButton.isEnabled = true
                    self.startButton.alpha = 1.0
                } else {
                    self.startButton.setTitle("학습하러 가기", for: .normal)
                    self.startButton.isEnabled = false
                    self.startButton.alpha = 0.5
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedSubjectIndex
            .drive(onNext: { [weak self] selectedIndex in
                guard let self = self else { return }
                for i in 0..<self.subjectCollectionView.numberOfItems(inSection: 0) {
                    if let cell = self.subjectCollectionView.cellForItem(at: IndexPath(item: i, section: 0)) as? HomeViewCollectionViewCell {
                        cell.setSelected(false)
                    }
                }
                
                if let selectedIndex = selectedIndex,
                   let cell = self.subjectCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? HomeViewCollectionViewCell {
                    cell.setSelected(true)
                }
            })
            .disposed(by: disposeBag)
        
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
        
        startButton.rx.tap
            .bind(to: fetchQuestionsRelay)
            .disposed(by: disposeBag)
    }
}

extension HomeViewController {
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
        
        questionViewController.completionHandler = { [weak self] results in
            guard let self = self else { return }
            let currentCount = UserDefaultsManager.shared.count
            self.progressLabel.text = "\(currentCount)개 완료!"
        }
        
        questionViewController.modalPresentationStyle = .fullScreen
        self.present(questionViewController, animated: true, completion: nil)
    }
    
    private func disableUI() {
        startButton.isEnabled = false
        subjectCollectionView.isUserInteractionEnabled = false
        print("UI Disabled")
    }
    
    private func enableUI() {
        if startButton.title(for: .normal) != "학습하러 가기" {
            startButton.isEnabled = true
            startButton.alpha = 1.0
        } else {
            startButton.isEnabled = false
            startButton.alpha = 0.5
        }
        
        subjectCollectionView.isUserInteractionEnabled = true
        print("UI Enabled")
    }
}
