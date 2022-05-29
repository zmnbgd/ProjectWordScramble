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
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        // Extra validation to come
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

