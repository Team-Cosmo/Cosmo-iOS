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
        let closeTrigger: Observable<Void>
        let menuTrigger: Observable<Void>
        let helpTrigger: Observable<Void>
        let submitTrigger: Observable<Void>
        let choiceSelected: Observable<Int>
        let startLearningTrigger: Observable<Void>
    }
    
    struct Output {
        let questions: Driver<[Question]>
        let currentQuestion: Driver<Question?>
        let questionCount: Driver<String>
        let choices: Driver<[String]>
        let closeAction: Driver<Void>
        let menuAction: Driver<Void>
        let helpAction: Driver<Void>
        let nextQuestionAction: Driver<Void>
    }
    
    private let questions = BehaviorRelay<[Question]>(value: [])
    private let currentQuestionIndex = BehaviorRelay<Int>(value: 0)
    private let selectedChoiceIndex = BehaviorRelay<Int?>(value: nil)
    
    init(fetchQuestionsUseCase: FetchQuestionsUseCase) {
        self.fetchQuestionsUseCase = fetchQuestionsUseCase
    }
    
    func transform(input: Input) -> Output {
        input.startLearningTrigger
            .flatMap { [weak self] _ -> Observable<[Question]> in
                guard let self = self else { return .just([]) }
                return self.fetchQuestionsUseCase.execute(subject: "운영체제")
            }
            .bind(to: questions)
            .disposed(by: disposeBag)
        
        let closeAction = input.closeTrigger
            .asDriver(onErrorJustReturn: ())
        
        let menuAction = input.menuTrigger
            .asDriver(onErrorJustReturn: ())
        
        let helpAction = input.helpTrigger
            .asDriver(onErrorJustReturn: ())
        
        input.choiceSelected
            .bind(to: selectedChoiceIndex)
            .disposed(by: disposeBag)
        
        let nextQuestionAction = input.submitTrigger
            .withLatestFrom(selectedChoiceIndex)
            .filter { $0 != nil }
            .map { _ in self.currentQuestionIndex.value + 1 }
            .do(onNext: { [weak self] nextIndex in
                self?.currentQuestionIndex.accept(nextIndex)
                self?.selectedChoiceIndex.accept(nil)
            })
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())
        
        let questionsOutput = questions.asDriver()
        
        let currentQuestionOutput = Observable.combineLatest(questions, currentQuestionIndex)
            .map { questions, index -> Question? in
                index < questions.count ? questions[index] : nil
            }
            .asDriver(onErrorJustReturn: nil)
        
        let questionCountOutput = Observable.combineLatest(currentQuestionIndex, questions)
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
            menuAction: menuAction,
            helpAction: helpAction,
            nextQuestionAction: nextQuestionAction
        )
    }
}
