//
//  QuestionRepository.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/7/25.
//

import Foundation
import RxSwift

protocol QuestionRepository {
    func fetchQuestions(subject: String) -> Observable<[Question]>
}

class QuestionRepositoryImpl: QuestionRepository {
    private let remoteDataSource: RemoteQuestionDataSource
    
    init(remoteDataSource: RemoteQuestionDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchQuestions(subject: String) -> Observable<[Question]> {
        return remoteDataSource.fetchQuestions(subject: subject)
    }
}
