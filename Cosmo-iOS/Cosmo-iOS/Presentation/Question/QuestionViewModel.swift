//
//  QuestionViewModel.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import Foundation
import RxSwift
import RxCocoa

class QuestionViewModel {
    private let disposeBag = DisposeBag()
    private let fetchQuestionsUseCase: FetchQuestionsUseCase
    
    struct Input {
        let questions: Observable<[Question]>
        let closeTrigger: Observable<Void>
//        let menuTrigger: Observable<Void>
//        let helpTrigger: Observable<Void>
        let submitTrigger: Observable<Void>
        let choiceSelected: Observable<Int>
    }
    
    struct Output {
        let questions: Driver<[Question]>
        let currentQuestion: Driver<Question?>
        let questionCount: Driver<String>
        let choices: Driver<[String]>
        let closeAction: Driver<Void>
//        let menuAction: Driver<Void>
//        let helpAction: Driver<Void>
        let nextQuestionAction: Driver<(Bool, Int)> // (isCorrect, correctAnswerIndex) 반환
    }
    
    private let questionsRelay = BehaviorRelay<[Question]>(value: [])
    private let currentQuestionIndex = BehaviorRelay<Int>(value: 0)
    private let selectedChoiceIndex = BehaviorRelay<Int?>(value: nil)
    
    init(fetchQuestionsUseCase: FetchQuestionsUseCase) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
    }
    
    func transform(input: Input) -> Output {
        input.questions
            .bind(to: questionsRelay)
            .disposed(by: disposeBag)
        
        let closeAction = input.closeTrigger.asDriver(onErrorJustReturn: ())
//        let menuAction = input.menuTrigger.asDriver(onErrorJustReturn: ())
//        let helpAction = input.helpTrigger.asDriver(onErrorJustReturn: ())
        
        input.choiceSelected
            .bind(to: selectedChoiceIndex)
            .disposed(by: disposeBag)
        
        let nextQuestionAction = input.submitTrigger
            .withLatestFrom(Observable.combineLatest(
                questionsRelay,
                currentQuestionIndex,
                selectedChoiceIndex
            ))
            .filter { _, _, selectedIndex in selectedIndex != nil }
            .flatMap { [weak self] questions, currentIndex, selectedIndex -> Observable<(Bool, Int)> in
                guard let self = self, let selectedIndex = selectedIndex else { return .just((false, 0)) }
                let correctAnswerIndex = questions[currentIndex].answer - 1
                let isCorrect = selectedIndex == correctAnswerIndex
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let nextIndex = currentIndex + 1
                    if nextIndex < questions.count {
                        self.currentQuestionIndex.accept(nextIndex)
                        self.selectedChoiceIndex.accept(nil)
                    }
                }
                
                return .just((isCorrect, correctAnswerIndex))
            }
            .asDriver(onErrorJustReturn: (false, 0))
        
        let questionsOutput = questionsRelay.asDriver()
        let currentQuestionOutput = Observable.combineLatest(questionsRelay, currentQuestionIndex)
            .map { questions, index -> Question? in
                index < questions.count ? questions[index] : nil
            }
            .asDriver(onErrorJustReturn: nil)
        
        let questionCountOutput = Observable.combineLatest(currentQuestionIndex, questionsRelay)
            .map { index, questions in "\(index + 1)/\(questions.count)" }
            .asDriver(onErrorJustReturn: "0/0")
        
        let choicesOutput = currentQuestionOutput
            .map { $0?.choices ?? [] }
        
        return Output(
            questions: questionsOutput,
            currentQuestion: currentQuestionOutput,
            questionCount: questionCountOutput,
            choices: choicesOutput,
            closeAction: closeAction,
            nextQuestionAction: nextQuestionAction
        )
    }
}
