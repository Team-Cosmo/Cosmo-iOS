//
//  FetchQuestionsUseCase.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/7/25.
//

import Foundation
import RxSwift

protocol FetchQuestionsUseCase {
    func execute(subject: String) -> Observable<[Question]>
}

class FetchQuestionsUseCaseImpl: FetchQuestionsUseCase {
    private let repository: QuestionRepository
    
    init(repository: QuestionRepository) {
        self.repository = repository
    }
    
    func execute(subject: String) -> Observable<[Question]> {
        return repository.fetchQuestions(subject: subject)
    }
}
