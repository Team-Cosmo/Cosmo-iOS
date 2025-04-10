//
//  RemoteQuestionDataSource.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/7/25.
//

import Foundation
import RxSwift

protocol RemoteQuestionDataSource {
    func fetchQuestions(subject: String) -> Observable<[Question]>
}

class RemoteQuestionDataSourceImpl: RemoteQuestionDataSource {
    private let maxRetryCount = 3
    
    func fetchQuestions(subject: String) -> Observable<[Question]> {
        return fetchQuestionsWithRetry(subject: subject, retryCount: 0)
    }
    
    private func fetchQuestionsWithRetry(subject: String, retryCount: Int) -> Observable<[Question]> {
        guard retryCount < maxRetryCount else {
            return .error(NSError(domain: "RemoteQuestionDataSource", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch valid questions after \(maxRetryCount) retries"]))
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return .error(NSError(domain: "RemoteQuestionDataSource", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(APIKey.read)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages = createMessages(for: subject)
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 2000,
            "temperature": 0.3
        ]
        
        guard let requestBody = try? JSONSerialization.data(withJSONObject: body) else {
            return .error(NSError(domain: "RemoteQuestionDataSource", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"]))
        }
        request.httpBody = requestBody
        
        return URLSession.shared.rx.data(request: request)
            .do(onNext: { data in
                print("Retry \(retryCount + 1)/\(self.maxRetryCount) - Received data from API: \(String(data: data, encoding: .utf8) ?? "Unable to decode data")")
            }, onError: { error in
                print("Retry \(retryCount + 1)/\(self.maxRetryCount) - Network request failed: \(error.localizedDescription)")
            })
                .flatMap { data -> Observable<[Question]> in
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    guard let content = response.choices.first?.message.content else {
                        throw NSError(domain: "RemoteQuestionDataSource", code: -3, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
                    }
                    
                    let questions = self.parseQuestions(from: content, subject: subject)
                    
                    if questions.count < 10 {
                        print("Retry \(retryCount + 1)/\(self.maxRetryCount) - Not enough questions (\(questions.count)). Retrying...")
                        return self.fetchQuestionsWithRetry(subject: subject, retryCount: retryCount + 1)
                    }
                    
                    return .just(questions)
                }
                .catch { error in
                    print("Retry \(retryCount + 1)/\(self.maxRetryCount) - Error during data mapping: \(error.localizedDescription)")
                    // 재시도
                    return self.fetchQuestionsWithRetry(subject: subject, retryCount: retryCount + 1)
                }
    }
    
    private func createMessages(for subject: String) -> [[String: Any]] {
        let formatInstruction = """
        Generate exactly 10 multiple-choice questions in the following format:
        [{"question": String, "choices": Array<String>, "answer": Int}]
        Each question must have exactly 4 choices, and the answer must be an integer between 1 and 4 (corresponding to the choice index, 1-based). All questions and choices must be written in Korean (Hangul). Return only the JSON array, do not include any additional text, explanations, or formatting outside the JSON array (e.g., no ```json markers). Strictly adhere to the specified format. The difficulty level should be intermediate. Ensure the response is a valid JSON array.
        """
        
        switch subject {
        case "all":
            return [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": "\(formatInstruction) The questions should cover topics from operating systems, data structures, algorithms, networks, and databases."]
            ]
        case "운영체제":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about operating systems(Computer Science)."]
            ]
        case "자료구조":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about data structures."]
            ]
        case "알고리즘":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about algorithms."]
            ]
        case "네트워크":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about networks."]
            ]
        case "데이터베이스":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about databases."]
            ]
        default:
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "\(formatInstruction) The questions should be about operating systems."]
            ]
        }
    }
    
    private func parseQuestions(from text: String, subject: String) -> [Question] {
        print("Original API response text: \(text)")
        
        var cleanedText = text.replacingOccurrences(of: "},\n{", with: "},{")
        cleanedText = cleanedText.replacingOccurrences(of: "\n", with: "")
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !cleanedText.hasPrefix("[") || !cleanedText.hasSuffix("]") {
            cleanedText = "[\(cleanedText)]"
        } else if cleanedText.hasPrefix("```json") && cleanedText.hasSuffix("```") {
            cleanedText = cleanedText.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        print("Cleaned JSON string: \(cleanedText)")
        
        let jsonData = Data(cleanedText.utf8)
        
        do {
            struct TempQuestion: Codable {
                let question: String
                let choices: [String]
                let answer: Int
            }
            
            let tempQuestions = try JSONDecoder().decode([TempQuestion].self, from: jsonData)
            let questions = tempQuestions.map { temp in
                Question(
                    id: UUID(),
                    question: temp.question,
                    choices: temp.choices,
                    answer: temp.answer
                )
            }
            print("Successfully parsed \(questions.count) questions")
            return questions
        } catch {
            print("Failed to parse questions: \(error)")
            print("Raw JSON string: \(cleanedText)")
            return []
        }
    }
    
    private struct RawQuestion: Codable {
        let question: String
        let choices: [String]
        let answer: Int
    }
}
