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
    private let progressRelay = BehaviorRelay<Int>(value: 0)
    private let selectedSubjectRelay = BehaviorRelay<String?>(value: nil)
    
    struct Input {
        let fetchQuestionsTrigger: Observable<Void>
        let selectSubjectTrigger: Observable<Int>
        let updateProgressTrigger: Observable<Int>
    }
    
    struct Output {
        let subjects: Driver<[(String, String)]>
        let fetchedQuestions: Driver<[Question]>
        let isLoading: Driver<Bool>
        let errorMessage: Driver<String?>
        let progress: Driver<Int>
        let selectedSubject: Driver<String?>
        let selectedSubjectIndex: Driver<Int?>
    }
    
    private let subjects = BehaviorRelay<[(String, String)]>(value: [
        ("운영체제", "img_operatingsystem"),
        ("자료구조", "img_datastructure"),
        ("알고리즘", "img_algorithm"),
        ("네트워크", "img_network"),
        ("데이터베이스", "img_database")
    ])
    
    private let selectedSubjectIndexRelay = BehaviorRelay<Int?>(value: nil)
    
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
        
        input.updateProgressTrigger
            .subscribe(onNext: { [weak self] correctCount in
                self?.progressRelay.accept(correctCount)
            })
            .disposed(by: disposeBag)
        
        input.selectSubjectTrigger
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.selectedSubjectIndexRelay.accept(index)
                let subject = self.getSubject(at: index)
                self.selectedSubjectRelay.accept(subject)
            })
            .disposed(by: disposeBag)
            
        let questions = input.fetchQuestionsTrigger
            .withLatestFrom(selectedSubjectRelay)
            .compactMap { $0 }  // Only proceed if subject is not nil
            .do(onNext: { _ in
                isLoading.accept(true)
                errorMessage.accept(nil)
            })
            .flatMapLatest { [weak self] subject -> Observable<[Question]> in
                guard let self = self else { return Observable.just([]) }
                return self.fetchQuestionsUseCase.execute(subject: subject)
                    .catch { error in
                        errorMessage.accept(error.localizedDescription)
                        print("Error fetching questions for subject \(subject): \(error.localizedDescription)")
                        return Observable.just([
                            Question(
                                id: UUID(),
                                question: "\(subject)란 무엇입니까?",
                                choices: ["하드웨어의 일종", "컴퓨터를 운영하는 소프트웨어", "인터넷 브라우저", "개발 도구"],
                                answer: 2
                            )
                        ])
                    }
            }
            .do(onNext: { _ in
                isLoading.accept(false)
            })
        
        return Output(
            subjects: subjects.asDriver(),
            fetchedQuestions: questions.asDriver(onErrorJustReturn: []),
            isLoading: isLoading.asDriver(),
            errorMessage: errorMessage.asDriver(),
            progress: progressRelay.asDriver(),
            selectedSubject: selectedSubjectRelay.asDriver(),
            selectedSubjectIndex: selectedSubjectIndexRelay.asDriver()
        )
    }
}
