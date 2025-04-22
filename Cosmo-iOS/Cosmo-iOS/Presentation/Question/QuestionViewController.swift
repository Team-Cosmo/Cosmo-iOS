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
//    let quizCompletedSubject = PublishSubject<Int>()
    
    private var questionResults: [QuestionResult] = []
    
    var completionHandler: (([QuestionResult]) -> Void)?
    
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
        button.setBackgroundImage(UIImage(named: "img_btn_cta"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    private var answerStates: [AnswerState] = Array(repeating: .none, count: 4)
    
    init(viewModel: QuestionViewModel, questions: [Question]) {
        self.viewModel = viewModel
        self.questions = questions
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
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    private func bind() {
        let input = QuestionViewModel.Input(
            questions: Observable.just(questions),
            closeTrigger: closeButton.rx.tap.asObservable(),
            menuTrigger: menuButton.rx.tap.asObservable(),
            helpTrigger: helpButton.rx.tap.asObservable(),
            submitTrigger: submitButton.rx.tap.asObservable(),
            choiceSelected: choicesCollectionView.rx.itemSelected.map { $0.item }
        )
        
        let output = viewModel.transform(input: input)
        
        output.questions
            .drive(with: self, onNext: { owner, questions in
                owner.questions = questions
                print("Loaded questions: \(questions.count)")
            })
            .disposed(by: disposeBag)
        
        output.currentQuestion
            .drive(with: self) { owner, question in
                guard let question = question else {
                    print("All questions completed")
                    owner.completionHandler?(owner.questionResults)
                    owner.dismiss(animated: true, completion: nil)
                    return
                }
                owner.questionLabel.text = question.question
                owner.selectedChoiceIndex.accept(nil)
                owner.answerStates = Array(repeating: .none, count: 4)
                owner.choicesCollectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.questionCount
            .drive(questionNumberLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.choices
            .drive(choicesCollectionView.rx.items(cellIdentifier: QuestionCollectionViewCell.identifier, cellType: QuestionCollectionViewCell.self)) { [weak self] (row, choice, cell) in
                //                cell.configure(with: choice, isSelected: row == self?.selectedChoiceIndex.value)
                let isSelected = row == self?.selectedChoiceIndex.value
                let answerState = self?.answerStates[row] ?? .none
                cell.configure(with: choice, isSelected: isSelected, answerState: answerState)
            }
            .disposed(by: disposeBag)
        
        choicesCollectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let selectedIndex = indexPath.row
                owner.selectedChoiceIndex.accept(selectedIndex)
                owner.choicesCollectionView.reloadData() // 선택 즉시 UI 갱신
            })
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
            .drive(with: self) { owner, result in
                let (isCorrect, correctAnswerIndex) = result
                
                let currentIndex = owner.currentQuestionIndex.value
                
                let question = owner.questions[currentIndex]
                let correctAnswerText = question.choices[question.answer - 1]
                let result = QuestionResult(
                    question: question.question,
                    answer: correctAnswerText,
                    isCorrect: isCorrect
                )
                owner.questionResults.append(result)
                
                let isLastQuestion = currentIndex == owner.questions.count - 1
                
                guard let selectedIndex = owner.selectedChoiceIndex.value else { return }
                
                var answerStates = Array(repeating: AnswerState.none, count: 4)
                if isCorrect {
                    answerStates[selectedIndex] = .correct
                    print("정답입니다!")
                } else {
                    answerStates[selectedIndex] = .wrong
                    answerStates[correctAnswerIndex] = .correct
                    print("오답입니다. 정답은 \(correctAnswerIndex + 1)번입니다.")
                }
                
                owner.answerStates = answerStates
                owner.choicesCollectionView.reloadData()
                
                owner.choicesCollectionView.isUserInteractionEnabled = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if isLastQuestion {
                        print("Moving to ResultViewController")
                        owner.completionHandler?(owner.questionResults)
//                        owner.dismiss(animated: true, completion: nil)
                        let resultVC = ResultViewController(results: owner.questionResults)
                        owner.modalPresentationStyle = .fullScreen
                        owner.present(resultVC, animated: true, completion: nil)
                        
                        owner.choicesCollectionView.isUserInteractionEnabled = true
                    } else {
                        let nextIndex = currentIndex + 1
                        owner.currentQuestionIndex.accept(nextIndex)
                        print("Moving to next question: \(nextIndex + 1)")
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
