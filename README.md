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

