//
//  ContentView.swift
//  MacReader
//
//  Created by Anastasia Ivanova on 05.01.25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext //  pulls the managedObjectContext from the environment & gives us access to the Core Data context
    
    @FetchRequest(
        entity: Book.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
    ) private var books: FetchedResults<Book>
    
    //  a property wrapper called @FetchRequest. It is used to automatically fetch data from Core Data and make it available to your SwiftUI view. A property wrapper is a special kind of code that changes how a variable behaves.
    
    // NSSortDescriptor is a class provided by the Foundation framework. It’s used to describe how data should be sorted in Core Data or other contexts where sorting is needed (e.g., arrays, table views). In Swift Core Data: Sorting Happens in the Query In Core Data (and databases in general), sorting happens at the database level, not in memory. When you create a FetchRequest in Core Data, you’re telling the database: “Fetch these records.”, “Sort them before they’re returned.” This is why we use NSSortDescriptor—to describe the sorting order as part of the query definition, not to sort objects in memory.

    @State private var searchQuery: String = ""

    func fetchBooks(for query: String) {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(query)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Fetched data: \(json)")
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
    }
    
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onAppear(){
                    print("Managed Object Context: \(viewContext)")
                }
            TextField("Search books...", text: $searchQuery) // Text input field
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .padding()
            // The $ in $searchQuery is part of SwiftUI’s property wrapper system and is used to create a binding. Whenever the value of searchQuery changes (e.g., when the user types in the TextField), SwiftUI will automatically rebuild the parts of the UI that depend on searchQuery. The TextField needs a binding so it can communicate back and forth with the variable. $ provides that.
            
            Button("Search") { // Button to trigger the search
                let sanitizedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !sanitizedQuery.isEmpty else {
                    print("Search query is empty")
                    return
                }
                fetchBooks(for: sanitizedQuery)
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
