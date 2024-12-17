//
//  ContentView.swift
//  iOSPolicyBot
//
//  Created by Kimberly Coston on 12/16/24.
//

import SwiftUI

struct ContentView: View {
    @State private var question: String = ""
    @State private var submittedQuestion: String = ""
    @State private var answer: String = "Your answer will appear here."
    @State private var isLoading: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Policy Chatbot")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Input for the question
                                TextField("Enter your question here", text: $question)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                

                // Submit button
                Button(action: {
                    askQuestion()
                }) {
                    Text(isLoading ? "Loading..." : "Send")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isLoading || question.isEmpty)

                // Display the submitted question
                if !submittedQuestion.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Question:")
                            .font(.headline)
                        Text(submittedQuestion)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Display the chatbot's answer
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chatbot Answer:")
                        .font(.headline)
                    Text(answer)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
    }

    func askQuestion() {
        guard let url = URL(string: "http://127.0.0.1:5000/query") else { return }
        isLoading = true
        submittedQuestion = question // Save the submitted question
        question = "" // Clear the input field

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["question": submittedQuestion]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false

            if let data = data, let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                DispatchQueue.main.async {
                    answer = decodedResponse.answer
                }
            } else {
                DispatchQueue.main.async {
                    answer = "Sorry, something went wrong. Please try again."
                }
            }
        }.resume()
    }
}

struct Response: Codable {
    let answer: String
}
