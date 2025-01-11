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
    
    @State private var fetchedBooks: [BookItem] = [] // Holds fetched books
    
    struct BookItem: Identifiable {
        let id: String
        let title: String
        let author: String
        let thumbnail: URL?
    }

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

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let items = json?["items"] as? [[String: Any]] else {
                    print("No items in response")
                    return
                }

                let books = items.compactMap { item -> BookItem? in
                    guard let id = item["id"] as? String,
                          let volumeInfo = item["volumeInfo"] as? [String: Any],
                          let title = volumeInfo["title"] as? String else {
                        return nil
                    }

                    let author: String
                    if let authors = volumeInfo["authors"] as? [String] {
                        author = authors.joined(separator: ", ")
                    } else {
                        author = "Unknown Author"
                    }
                    
                    let thumbnail: URL?
                    if let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                       let thumbnailString = imageLinks["thumbnail"] as? String {
                        // Fix URL encoding issues (if any) by ensuring it's a valid URL
                        thumbnail = URL(string: thumbnailString.replacingOccurrences(of: "http://", with: "https://"))
                    } else {
                        thumbnail = nil
                    }
                    
                    return BookItem(id: id, title: title, author: author, thumbnail: thumbnail)
                }

                DispatchQueue.main.async {
                    self.fetchedBooks = books
                }
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
            TextField("Search books...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit { // Trigger search when Enter is pressed
                    let sanitizedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !sanitizedQuery.isEmpty else {
                        print("Search query is empty")
                        return
                    }
                    fetchBooks(for: sanitizedQuery)
                }
            // The $ in $searchQuery is part of SwiftUI’s property wrapper system and is used to create a binding. Whenever the value of searchQuery changes (e.g., when the user types in the TextField), SwiftUI will automatically rebuild the parts of the UI that depend on searchQuery. The TextField needs a binding so it can communicate back and forth with the variable. $ provides that.
            
            Button("Search") { // Button to trigger the search
                let sanitizedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !sanitizedQuery.isEmpty else {
                    print("Search query is empty")
                    return
                }
                fetchBooks(for: sanitizedQuery)
            }
            
            List(fetchedBooks) { book in
                HStack {
                    if let thumbnail = book.thumbnail {
                        AsyncImage(url: thumbnail) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
