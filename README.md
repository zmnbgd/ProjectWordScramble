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


Running code when our app launches



When Xcode builds an iOS project, it puts your compiled program, your asset catalog, and any other assets into a single directory called a bundle, then gives that bundle the name YourAppName.app. This “.app” extension is automatically recognized by iOS and Apple’s other platforms, which is why if you double-click something like Notes.app on macOS it knows to launch the program inside the bundle.

In our game, we’re going to include a file called “start.txt”, which includes over 10,000 eight-letter words that will be randomly selected for the player to work with.

We already defined a property called rootWord, which will contain the word we want the player to spell from. What we need to do now is write a new method called startGame() that will:

1. Find start.txt in our bundle
2. Load it into a string
3. Split that string into array of strings, with each element being one word
4. Pick one random word from there to be assigned to rootWord, or use a sensible default if the array is empty.

Each of those four tasks corresponds to one line of code, but there’s a twist: what if we can’t locate start.txt in our app bundle, or if we can locate it but we can’t load it? In that case we have a serious problem, because our app is really broken – either we forgot to include the file somehow (in which case our game won’t work), or we included it but for some reason iOS refused to let us read it (in which case our game won’t work, and our app is broken).

Regardless of what caused it, this is a situation that never ought to happen, and Swift gives us a function called fatalError() that lets us respond to unresolvable problems really clearly. When we call fatalError() it will – unconditionally and always – cause our app to crash. It will just die. Not “might die” or “maybe die”: it will always just terminate straight away.

I realize that sounds bad, but what it lets us do is important: for problems like this one, such as if we forget to include a file in our project, there is no point trying to make our app struggle on in a broken state. It’s much better to terminate immediately and give us a clear explanation of what went wrong so we can correct the problem, and that’s exactly what fatalError() does.

Anyway, let’s take a look at the code – I’ve added comments matching the numbers above:

func startGame() {
    // 1. Find the URL for start.txt in our app bundle
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
        // 2. Load start.txt into a string
        if let startWords = try? String(contentsOf: startWordsURL) {
            // 3. Split the string up into an array of strings, splitting on line breaks
            let allWords = startWords.components(separatedBy: "\n")

            // 4. Pick one random word, or use "silkworm" as a sensible default
            rootWord = allWords.randomElement() ?? "silkworm"

            // If we are here everything has worked, so we can exit
            return
        }
    }

    // If were are *here* then there was a problem – trigger a crash and report the error
    fatalError("Could not load start.txt from bundle.")
}

Now that we have a method to load everything for the game, we need to actually call that thing when our view is shown. SwiftUI gives us a dedicated view modifier for running a closure when a view is shown, so we can use that to call startGame() and get things moving – add this modifier after onSubmit():

.onAppear(perform: startGame)



Validating words with UITextChecker


Now that our game is all set up, the last part of this project is to make sure the user can’t enter invalid words. We’re going to implement this as four small methods, each of which perform exactly one check: is the word original (it hasn’t been used already), is the word possible (they aren’t trying to spell “car” from “silkworm”), and is the word real (it’s an actual English word).

If you were paying attention you’ll have noticed that was only three methods – that’s because the fourth method will be there to make showing error messages easier.

Anyway, let’s start with the first method: this will accept a string as its only parameter, and return true or false depending on whether the word has been used before or not. We already have a usedWords array, so we can pass the word into its contains() method and send the result back like this:

func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
}

That’s one method down!

The next one is slightly trickier: how can we check whether a random word can be made out of the letters from another random word?

There are a couple of ways we could tackle this, but the easiest one is this: if we create a variable copy of the root word, we can then loop over each letter of the user’s input word to see if that letter exists in our copy. If it does, we remove it from the copy (so it can’t be used twice), then continue. If we make it to the end of the user’s word successfully then the word is good, otherwise there’s a mistake and we return false.

So, here’s our second method:

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

The final method is harder, because we need to use UITextChecker from UIKit. In order to bridge Swift strings to Objective-C strings safely, we need to create an instance of NSRange using the UTF-16 count of our Swift string. This isn’t nice, I know, but I’m afraid it’s unavoidable until Apple cleans up these APIs.

So, our last method will make an instance of UITextChecker, which is responsible for scanning strings for misspelled words. We’ll then create an NSRange to scan the entire length of our string, then call rangeOfMisspelledWord() on our text checker so that it looks for wrong words. When that finishes we’ll get back another NSRange telling us where the misspelled word was found, but if the word was OK the location for that range will be the special value NSNotFound.
So, here’s our final method:

func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

    return misspelledRange.location == NSNotFound
}

Before we can use those three, I want to add some code to make showing error alerts easier. First, we need some properties to control our alerts:

@State private var errorTitle = ""
@State private var errorMessage = ""
@State private var showingError = false

Now we can add a method that sets the title and message based on the parameters it receives, then flips the showingError Boolean to true:

func wordError(title: String, message: String) {
    errorTitle = title
    errorMessage = message
    showingError = true
}

We can then pass those directly on to SwiftUI by adding an alert() modifier below .onAppear():

.alert(errorTitle, isPresented: $showingError) {
    Button("OK", role: .cancel) { }
} message: {
    Text(errorMessage)
}

We’ve done that several times now, so hopefully it’s becoming second nature!

At long last it’s time to finish our game: replace the // extra validation to come comment in addNewWord() with this:

guard isOriginal(word: answer) else {
    wordError(title: "Word used already", message: "Be more original")
    return
}

guard isPossible(word: answer) else {
    wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
    return
}

guard isReal(word: answer) else {
    wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
    return
}



