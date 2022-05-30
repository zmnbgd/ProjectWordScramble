//
//  ContentView.swift
//  WordScramble
//
//  Created by Marko Zivanovic on 18.5.22..
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            
            .onSubmit(addNewWord)

            .onAppear(perform: startGame)
            
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        // Extra validation to come
        
        guard isOriginal(word: answer) else {
            wordError(title: "word is used already", message: "be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possiblle", message: "You can't spell taht word")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Wprd not recognized", message: "You can't just make them up")
            return 
        }
        
        
        withAnimation {
        usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        // Find the URL for start.txt in bundle app
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
               // Split the string up into a array of strings, split on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                // Pick up random word or silkworm as sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
               // if we are here everything has worked, so we can exit
                return
            }
        }
        //If we are here then we have a problem - trigger a crash and report error 
        fatalError("Could not load tart.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
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
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

