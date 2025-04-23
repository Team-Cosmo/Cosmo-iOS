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
        label.font = UIFont(name: "Pretendard-Bold", size: 22)
        label.textColor = .black
        
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "좌우 드래그를 통해 수치를 조정할 수 있어요"
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Medium", size: 16)
        label.textColor = .gray
        return label
    }()
    
    private let beginnerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_onboarding_2_left")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let expertImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_onboarding_2_right")
        imageView.contentMode = .scaleAspectFill
        
        return imageView
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
        button.setBackgroundImage(UIImage(named: "img_btn_cta"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 22)
        
        return button
    }()
    
    private let subjects = BehaviorRelay<[String]>(value: [])
    
    private var sliderValues: [String: Float] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func setSubjects(_ subjects: [String]) {
        self.subjects.accept(subjects)
        subjects.forEach { subject in
            sliderValues[subject] = 0
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(beginnerImageView)
        view.addSubview(expertImageView)
        view.addSubview(collectionView)
        view.addSubview(completeButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
//            make.horizontalEdges.equalToSuperview().inset(-55)
        }
        
        beginnerImageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(122)
            make.height.equalTo(42)
        }
        
        expertImageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-32)
            make.width.equalTo(122)
            make.height.equalTo(42)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(beginnerImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(completeButton.snp.top).offset(-20)
        }
        
        completeButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func bind() {
        subjects
            .bind(to: collectionView.rx.items(cellIdentifier: OnBoardingCompetencyCollectionViewCell.identifier, cellType: OnBoardingCompetencyCollectionViewCell.self)) { [weak self] (row, element, cell) in
                cell.configure(subject: element)
                cell.slider.value = self?.sliderValues[element] ?? 0
                cell.onSliderValueChanged = { value in
                    self?.sliderValues[element] = value
                    print("\(element) 슬라이더 값: \(value)")
                }
            }
            .disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                UserDefaultsManager.shared.isStart = true
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else { return }
                
                window.rootViewController = owner.moveToHomeViewController()
                window.makeKeyAndVisible()
                owner.navigationController?.pushViewController(owner.moveToHomeViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension OnBoardingCompetencyViewController {
    private func moveToHomeViewController() -> HomeViewController {
        let qusetionrepo = QuestionRepositoryImpl(remoteDataSource: RemoteQuestionDataSourceImpl())
        let fetchQuestionsUseCase = FetchQuestionsUseCaseImpl(repository: qusetionrepo)
        
        let viewModel = HomeViewModel(fetchQuestionsUseCase: fetchQuestionsUseCase)
        
        let homeVC = HomeViewController(viewModel: viewModel)
        
        return homeVC
    }
}
