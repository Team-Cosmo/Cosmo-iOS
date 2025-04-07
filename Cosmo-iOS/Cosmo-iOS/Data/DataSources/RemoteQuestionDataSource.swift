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
    func fetchQuestions(subject: String) -> Observable<[Question]> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return .error(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
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
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.rx.data(request: request)
            .map { data -> [Question] in
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                guard let content = response.choices.first?.message.content else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
                }
                return self.parseQuestions(from: content)
            }
    }
    
    private func createMessages(for subject: String) -> [[String: Any]] {
        switch subject {
        case "all":
            return [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": "Generates a total of 10 multiple-choice questions about the operating system, data structure, algorithms, networks, and databases in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        case "운영체제":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about operating systems in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개고 해당하는 string만 적어줘, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        case "자료구조":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about data structure in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        case "알고리즘":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about algorithm in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        case "네트워크":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about network in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        case "데이터베이스":
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about database in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        default:
            return [
                ["role": "system", "content": "You are a professional software programmer."],
                ["role": "user", "content": "Generate 10 multiple-choice questions about operating systems in the following format:\n{\"question\": String,\n\"choices\": Array<String>,\n\"answer\": Int\n} in korean, 선지는 총 4개야, 정답은 선지에 해당하는 1에서 4사이의 숫자로 적어줘, 데이터 이외에는 넘기지 말아줘, 마지막으로 반드시 데이터 형식을 지켜줘 그리고 난이도는 중간 이상이야"]
            ]
        }
    }
    
    private func parseQuestions(from text: String) -> [Question] {
        let jsonData = Data(text.utf8)
        do {
            return try JSONDecoder().decode([Question].self, from: jsonData)
        } catch {
            print("Failed to parse questions: \(error.localizedDescription)")
            return []
        }
    }
}
