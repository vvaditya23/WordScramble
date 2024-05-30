//
//  ContentView.swift
//  WordScramble
//
//  Created by Aditya Vyavahare on 26/05/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        Text(word)
                    }
                }
            }
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .alert(errorTitle, isPresented: $showError) {
                Button("Okay") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let userAnswer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard userAnswer.count >= 3 else {
            return wordError(title: "Word too short!", message: "You have entered a very short word.")
        }
        
        //more validations to come
        guard isUnique(word: userAnswer) else {
            return wordError(title: "Word already used.", message: "Enter some unique word.")
        }
        
        guard isPossible(word: userAnswer) else {
            return wordError(title: "Invalid word!", message: "Please enter a valid word.")
        }
        
        guard isReal(word: userAnswer) else {
            return wordError(title: "Word not recognized!", message: "Spelling of word is incorrect, Check your spelling.")
        }
        
        usedWords.insert(userAnswer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //we get the file URL
            if let startWords = try? String(contentsOf: startWordsURL) {
                //we load contents of file in string
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "apple"
                return
            } else {
                //failed to load comntents of file
                fatalError("could not load contents of file.")
            }
        } else {
            //no file url
            fatalError("Could not load start.txt from bundle.")
        }
    }
    
    //checks for user I/P
    func isUnique(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var rootwordCopy = rootWord
        
        for letter in word {
            if let position = rootwordCopy.firstIndex(of: letter) {
                rootwordCopy.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

#Preview {
    ContentView()
}
