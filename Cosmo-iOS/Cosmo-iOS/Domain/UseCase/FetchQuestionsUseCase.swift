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
            .map { questions -> [Question] in
                guard questions.count >= 10 else {
                    throw NSError(domain: "FetchQuestionsUseCase", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not enough questions returned: \(questions.count)"])
                }
                return questions
            }
            .catch { error in
                print("FetchQuestionsUseCase error: \(error.localizedDescription)")
                return .just([]) 
            }
    }
}
