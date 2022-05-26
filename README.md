DAY 29 


Unicode is a standard for storing and representing text, which at first glance you might think sounds easy.

But it really isn’t.

The game will show players a random eight-letter word, and ask them to make words out of it. For example, if the starter word is “alarming” they might spell “alarm”, “ring”, “main”, and so on.

Along the way you’ll meet List, onAppear(), Bundle, fatalError(), and more – all useful skills that you’ll use for years to come. You’ll also get some practice with @State, NavigationView.


Introducing List, your best friend


Of all SwiftUI’s view types, List is the one you’ll rely on the most. The equivalent of List in UIKit was UITableView, and it got used just as much.

The job of List is to provide a scrolling table of data. In fact, it’s pretty much identical to Form, except it’s used for presentation of data rather than requesting user input. Don’t get me wrong: you’ll use Form quite a lot too, but really it’s just a specialized type of List.

Just like Form, you can provide List a selection of static views to have them rendered in individual rows:

List {
    Text("Hello World")
    Text("Hello World")
    Text("Hello World")
}

We can also switch to ForEach in order to create rows dynamically from an array or range:

List {
    ForEach(0..<5) {
        Text("Dynamic row \($0)")
    }
}

Where things get more interesting is the way you can mix static and dynamic rows:
List {
    Text("Static row 1")
    Text("Static row 2")

    ForEach(0..<5) {
        Text("Dynamic row \($0)")
    }

    Text("Static row 3")
    Text("Static row 4")
}

And of course we can combine that with sections, to make our list easier to read:
List {
    Section("Section 1") {
        Text("Static row 1")
        Text("Static row 2")
    }

    Section("Section 2") {
        ForEach(0..<5) {
            Text("Dynamic row \($0)")
        }
    }

    Section("Section 3") {
        Text("Static row 3")
        Text("Static row 4")
    }
}

Being able to have both static and dynamic content side by side lets us recreate something like the Wi-Fi screen in Apple’s Settings app – a toggle to enable Wi-Fi system-wide, then a dynamic list of nearby networks, then some more static cells with options to auto-join hotspots and so on.

You’ll notice that this list looks similar to the form we had previously, but we can adjust how the list looks using the listStyle() modifier, like this:
.listStyle(.grouped)

Now, everything you’ve seen so far works fine with Form as well as List – even the dynamic content. But one thing List can do that Form can’t is to generate its rows entirely from dynamic content without needing a ForEach.

So, if your entire list is made up of dynamic rows, you can simply write this:

List(0..<5) {
    Text("Dynamic row \($0)")
}

This allows us to create lists really quickly, which is helpful given how common they are.

In this project we’re going to use List slightly differently, because we’ll be making it loop over an array of strings. We’ve used ForEach with ranges a lot, either hard-coded (0..<5) or relying on variable data (0..<students.count), and that works great because SwiftUI can identify each row uniquely based on its position in the range.

When working with an array of data, SwiftUI still needs to know how to identify each row uniquely, so if one gets removed it can simply remove that one rather than having to redraw the whole list. This is where the id parameter comes in, and it works identically in both List and ForEach – it lets us tell SwiftUI exactly what makes each item in the array unique.

When working with arrays of strings and numbers, the only thing that makes those values unique is the values themselves. That is, if we had the array [2, 4, 6, 8, 10], then those numbers themselves are themselves the unique identifiers. After all, we don’t have anything else to work with!

When working with this kind of list data, we use id: \.self like this:

struct ContentView: View {
    let people = ["Finn", "Leia", "Luke", "Rey"]

    var body: some View {
        List(people, id: \.self) {
            Text($0)
        }
    }
}

That works just the same with ForEach, so if we wanted to mix static and dynamic rows we could have written this instead:

List {
    Text("Static Row")

    ForEach(people, id: \.self) {
        Text($0)
    }

    Text("Static Row")
}



Loading resources from your app bundle


When we use Image views, SwiftUI knows to look in your app’s asset catalog to find the artwork, and it even automatically adjusts the artwork so it loads the correct picture for the current screen resolution – that’s the @2x and @3x stuff we looked at earlier.

For other data, such as text files, we need to do more work. This also applies if you have specific data formats such as XML or JSON – it takes the same work regardless of what file types you’re loading.

When Xcode builds your iOS app, it creates something called a “bundle”. This happens on all of Apple’s platforms, including macOS, and it allows the system to store all the files for a single app in one place – the binary code (the actual compiled Swift stuff we wrote), all the artwork, plus any extra files we need all in one place.


In the future, as your skills grow, you’ll learn how you can actually include multiple bundles in a single app, allowing you to write things like Siri extensions, iMessage apps, widgets, and more, all inside a single iOS app bundle. Although these get included with our app’s download from the App Store, these other bundles are stored separately from our main app bundle – our main iOS app code and resources.

All this matters because it’s common to want to look in a bundle for a file you placed there. This uses a new data type called URL, which stores pretty much exactly what you think: a URL such as https://www.hackingwithswift.com. However, URLs are a bit more powerful than just storing web addresses – they can also store the locations of files, which is why they are useful here.

Let’s start writing some code. If we want to read the URL for a file in our main app bundle, we use Bundle.main.url(). If the file exists it will be sent back to us, otherwise we’ll get back nil, so this is an optional URL. That means we need to unwrap it like this:

if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
    // we found the file in our bundle!
}

What’s inside the URL doesn’t really matter, because iOS uses paths that are impossible to guess – our app lives in its own sandbox, and we shouldn’t try to read outside of it.

Once we have a URL, we can load it into a string with a special initializer: String(contentsOf:). We give this a file URL, and it will send back a string containing the contents of that file if it can be loaded. If it can’t be loaded it throws an error, so you you need to call this using try or try? like this:

if let fileContents = try? String(contentsOf: fileURL) {
    // we loaded the file into a string!
}

Once you have the contents of the file, you can do with it whatever you want – it’s just a regular string.



Working with strings


iOS gives us some really powerful APIs for working with strings, including the ability to split them into an array, remove whitespace, and even check spellings. We’ve looked at some of these previously, but there’s at least one major addition I want to look at.

In this app, we’re going to be loading a file from our app bundle that contains over 10,000 eight-letter words, each of which can be used to start the game. These words are stored one per line, so what we really want is to split that string up into an array of strings in order that we can pick one randomly.

Swift gives us a method called components(separatedBy:) that can converts a single string into an array of strings by breaking it up wherever another string is found. For example, this will create the array ["a", "b", "c"]:

let input = "a b c"
let letters = input.components(separatedBy: " ")

We have a string where words are separated by line breaks, so to convert that into a string array we need to split on that.
In programming – almost universally, I think – we use a special character sequence to represent line breaks: \n. So, we would write code like this:

let input = """
            a
            b
            c
            """
let letters = input.components(separatedBy: "\n")

Regardless of what string we split on, the result will be an array of strings. From there we can read individual values by indexing into the array, such as letters[0] or letters[2], but Swift gives us a useful other option: the randomElement() method returns one random item from the array.

For example, this will read a random letter from our array:

let letter = letters.randomElement()

Now, although we can see that the letters array will contain three items, Swift doesn’t know that – perhaps we tried to split up an empty string, for example. As a result, the randomElement() method returns an optional string, which we must either unwrap or use with nil coalescing.

Another useful string method is trimmingCharacters(in:), which asks Swift to remove certain kinds of characters from the start and end of a string. This uses a new type called CharacterSet, but most of the time we want one particular behavior: removing whitespace and new lines – this refers to spaces, tabs, and line breaks, all at once.

This behavior is so common it’s built right into the CharacterSet struct, so we can ask Swift to trim all whitespace at the start and end of a string like this:

let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)

There’s one last piece of string functionality I’d like to cover before we dive into the main project, and that is the ability to check for misspelled words.

This functionality is provided through the class UITextChecker. You might not realize this, but the “UI” part of that name carries two additional meanings with it:

1. This class comes from UIKit. That doesn’t mean we’re loading all the old user interface framework, though; we actually get it automatically through SwiftUI.
2. It’s written using Apple’s older language, Objective-C. We don’t need to write Objective-C to use it, but there is a slightly unwieldy API for Swift users.
3. 
Checking a string for misspelled words takes four steps in total. First, we create a word to check and an instance of UITextChecker that we can use to check that string:

let word = "swift"
let checker = UITextChecker()

Second, we need to tell the checker how much of our string we want to check. If you imagine a spellchecker in a word processing app, you might want to check only the text the user selected rather than the entire document.

However, there’s a catch: Swift uses a very clever, very advanced way of working with strings, which allows it to use complex characters such as emoji in exactly the same way that it uses the English alphabet. However, Objective-C does not use this method of storing letters, which means we need to ask Swift to create an Objective-C string range using the entire length of all our characters, like this:

let range = NSRange(location: 0, length: word.utf16.count)

UTF-16 is what’s called a character encoding – a way of storing letters in a string. We use it here so that Objective-C can understand how Swift’s strings are stored; it’s a nice bridging format for us to connect the two.

Third, we can ask our text checker to report where it found any misspellings in our word, passing in the range to check, a position to start within the range (so we can do things like “Find Next”), whether it should wrap around once it reaches the end, and what language to use for the dictionary:

let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

That sends back another Objective-C string range, telling us where the misspelling was found. Even then, there’s still one complexity here: Objective-C didn’t have any concept of optionals, so instead relied on special values to represent missing data.

In this instance, if the Objective-C range comes back as empty – i.e., if there was no spelling mistake because the string was spelled correctly – then we get back the special value NSNotFound.

So, we could check our spelling result to see whether there was a mistake or not like this:

let allGood = misspelledRange.location == NSNotFound




DAY 30


Today you have three topics to work through, and you’ll put into practice everything you learned about List, UITextChecker, and more.

The user interface for this app will be made up of three main SwiftUI views: a NavigationView showing the word they are spelling from, a TextField where they can enter one answer, and a List showing all the words they have entered previously.
For now, every time users enter a word into the text field, we’ll automatically add it to the list of used words. Later, though, we’ll add some validation to make sure the word hasn’t been used before, can actually be produced from the root word they’ve been given, and is a real word and not just some random letters.

Let’s start with the basics: we need an array of words they have already used, a root word for them to spell other words from, and a string we can bind to a text field. So, add these three properties to ContentView now:

@State private var usedWords = [String]()
@State private var rootWord = ""
@State private var newWord = ""

As for the body of the view, we’re going to start off as simple as possible: a NavigationView with rootWord for its title, then a couple of sections inside a list:

var body: some View {
    NavigationView {
        List {
            Section {
                TextField("Enter your word", text: $newWord)
            }

            Section {
                ForEach(usedWords, id: \.self) { word in
                    Text(word)
                }
            }
        }
        .navigationTitle(rootWord)
    }
}

Note: Using id: \.self would cause problems if there were lots of duplicates in usedWords, but soon enough we’ll be disallowing that so it’s not a problem.

Now, our text view has a problem: although we can type into the text box, we can’t submit anything from there – there’s no way of adding our entry to the list of used words.

To fix that we’re going to write a new method called addNewWord() that will:

1. Lowercase newWord and remove any whitespace
2. Check that it has at least 1 character otherwise exit
3. Insert that word at position 0 in the usedWords array
4. Set newWord back to be an empty string
We 
Later on we’ll add some extra validation between steps 2 and 3 to make sure the word is allowable, but for now this method is straightforward:

func addNewWord() {
    // lowercase and trim the word, to make sure we don't add duplicate words with case differences
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    // exit if the remaining string is empty
    guard answer.count > 0 else { return }

    // extra validation to come

    usedWords.insert(answer, at: 0)
    newWord = ""
}

We want to call addNewWord() when the user presses return on the keyboard, and in SwiftUI we can do that by adding an onSubmit() modifier somewhere in our view hierarchy – it could be directly on the button, but it can be anywhere else in the view because it will be triggered when any text is submitted.

onSubmit() needs to be given a function that accepts no parameters and returns nothing, which exactly matches the addNewWord() method we just wrote. So, we can pass that in directly by adding this modifier below navigationTitle():

.onSubmit(addNewWord) 

Run the app now and you’ll see that things are starting to come together already: we can now type words into the text field, press return, and see them appear in the list.

Inside addNewWord() we used usedWords.insert(answer, at: 0) for a reason: if we had used append(answer) the new words would have appeared at the end of the list where they would probably be off screen, but by inserting words at the start of the array they automatically appear at the top of the list – much better.

Before we put a title up in the navigation view, I’m going to make two small changes to our layout.

First, when we call addNewWord() it lowercases the word the user entered, which is helpful because it means the user can’t add “car”, “Car”, and “CAR”. However, it looks odd in practice: the text field automatically capitalizes the first letter of whatever the user types, so when they submit “Car” what they see in the list is “car”.

To fix this, we can disable capitalization for the text field with another modifier: textInputAutocapitalization(). Please add this to the text field now:

.textInputAutocapitalization(.never)

The second thing we’ll change, just because we can, is to use Apple’s SF Symbols icons to show the length of each word next to the text. SF Symbols provides numbers in circles from 0 through 50, all named using the format “x.circle.fill” – so 1.circle.fill, 20.circle.fill.

In this program we’ll be showing eight-letter words to users, so if they rearrange all those letters to make a new word the longest it will be is also eight letters. As a result, we can use those SF Symbols number circles just fine – we know that all possible word lengths are covered.

So, we can wrap our word text in a HStack, and place an SF Symbol next to it using Image(systemName:)` like this:

ForEach(usedWords, id: \.self) { word in
    HStack {
        Image(systemName: "\(word.count).circle")
        Text(word)
    }
}

If you run the app now you’ll see you can type words in the text field, press return, then see them appear in the list with their length icon to the side. Nice!

Now, if you wanted to we could add one sneaky little extra tweak in here. When we submit our text field right now, the text just appears in the list immediately, but we could animate that by modifying the insert() call inside addNewWord() to this:

withAnimation {
    usedWords.insert(answer, at: 0)
}




