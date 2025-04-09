//
//  HomeViewModel.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/8/25.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    private let disposeBag = DisposeBag()
        private let fetchQuestionsUseCase: FetchQuestionsUseCase

        struct Input {
            let fetchQuestionsTrigger: Observable<String>
            let startLearningTrigger: Observable<Void>
        }
        
        struct Output {
            let subjects: Driver<[(String, String)]>
            let fetchedQuestions: Driver<[Question]>
            let isLoading: Driver<Bool>
            let errorMessage: Driver<String?>
        }
        
        private let subjects = BehaviorRelay<[(String, String)]>(value: [
            ("운영체제", "img_operatingsystem"),
            ("자료구조", "img_datastructure"),
            ("알고리즘", "img_algorithm"),
            ("네트워크", "img_network"),
            ("데이터베이스", "img_database")
        ])
        
        func getSubject(at index: Int) -> String {
            guard index >= 0 && index < subjects.value.count else { return "운영체제" }
            return subjects.value[index].0
        }
        
        init(fetchQuestionsUseCase: FetchQuestionsUseCase) {
            self.fetchQuestionsUseCase = fetchQuestionsUseCase
        }
        
        func transform(input: Input) -> Output {
            let isLoading = BehaviorRelay<Bool>(value: false)
            let errorMessage = BehaviorRelay<String?>(value: nil)
            
            let questions = Observable.merge(
                input.fetchQuestionsTrigger.map { subject in (subject: subject, isAll: false) },
                input.startLearningTrigger.map { _ in (subject: "all", isAll: true) }
            )
                .do(onNext: { _ in
                    isLoading.accept(true)
                    errorMessage.accept(nil)
                })
                .flatMapLatest { [weak self] (subject, isAll) -> Observable<[Question]> in
                    guard let self = self else { return Observable.just([]) }
                    return self.fetchQuestionsUseCase.execute(subject: subject)
                        .catch { error in
                            errorMessage.accept(error.localizedDescription)
                            print("Error fetching questions for subject \(subject): \(error.localizedDescription)")
                            return Observable.just([
                                Question(
                                    id: UUID(),
                                    question: isAll ? "운영체제란 무엇입니까?" : "\(subject)란 무엇입니까?",
                                    choices: ["하드웨어의 일종", "컴퓨터를 운영하는 소프트웨어", "인터넷 브라우저", "개발 도구"],
                                    answer: 2
                                )
                            ])
                        }
                }
                .do(onNext: { _ in
                    isLoading.accept(false)
                })
            
            let fetchedQuestions = Observable.merge(
                questions
            )
            .asDriver(onErrorJustReturn: [])
            
            return Output(
                subjects: subjects.asDriver(),
                fetchedQuestions: fetchedQuestions,
                isLoading: isLoading.asDriver(),
                errorMessage: errorMessage.asDriver()
            )
        }
}
