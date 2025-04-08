//
//  QuestionViewController.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class QuestionViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: QuestionViewModel
    private var questions: [Question] = []
    private let currentQuestionIndex = BehaviorRelay<Int>(value: 0)
    private let selectedChoiceIndex = BehaviorRelay<Int?>(value: nil)
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let questionNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "1/10"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let choicesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 60)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let helpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("HELP AI", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 20
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("제출할게요", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    init(viewModel: QuestionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(closeButton)
        view.addSubview(questionNumberLabel)
        view.addSubview(menuButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        
        questionNumberLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.centerX.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(30)
        }
    
        view.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        choicesCollectionView.register(QuestionCollectionViewCell.self, forCellWithReuseIdentifier: QuestionCollectionViewCell.identifier)
        view.addSubview(choicesCollectionView)
        choicesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
        
        view.addSubview(helpButton)
        helpButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func bind() {
        // Input 정의
        let input = QuestionViewModel.Input(
            closeTrigger: closeButton.rx.tap.asObservable(),
            menuTrigger: menuButton.rx.tap.asObservable(),
            helpTrigger: helpButton.rx.tap.asObservable(),
            submitTrigger: submitButton.rx.tap.asObservable(),
            choiceSelected: choicesCollectionView.rx.itemSelected.map { $0.item },
            startLearningTrigger: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        output.questions
            .drive(with: self, onNext: { owner, questions in
                owner.questions = questions
                print("Loaded questions: \(questions.count)")
            })
            .disposed(by: disposeBag)
        
        output.currentQuestion
            .drive(with: self, onNext: { owner, question in
                guard let question = question else {
                    print("All questions completed")
                    owner.dismiss(animated: true, completion: nil)
                    return
                }
                owner.questionLabel.text = question.question
            })
            .disposed(by: disposeBag)
        
        output.questionCount
            .drive(questionNumberLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.choices
            .drive(choicesCollectionView.rx.items(cellIdentifier: QuestionCollectionViewCell.identifier, cellType: QuestionCollectionViewCell.self)) { [weak self] (row, choice, cell) in
                cell.configure(with: choice, isSelected: row == self?.selectedChoiceIndex.value)
            }
            .disposed(by: disposeBag)
        
        output.closeAction
            .drive(with: self, onNext: { owner, _ in
                owner.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        output.menuAction
            .drive(with: self, onNext: { owner, _ in
                print("Menu button tapped")
                // TODO: 메뉴 화면으로 전환
            })
            .disposed(by: disposeBag)
        
        output.helpAction
            .drive(with: self, onNext: { owner, _ in
                print("HELP AI button tapped")
                // TODO: 도움말 화면 표시
            })
            .disposed(by: disposeBag)
        
        output.nextQuestionAction
            .drive(with: self, onNext: { owner, _ in
                print("Moved to next question")
            })
            .disposed(by: disposeBag)
    }
    
    private func moveToNextQuestion() {
        guard selectedChoiceIndex.value != nil else {
            print("선지를 선택해주세요!")
            return
        }
        
        let nextIndex = currentQuestionIndex.value + 1
        currentQuestionIndex.accept(nextIndex)
        selectedChoiceIndex.accept(nil) 
    }
}
