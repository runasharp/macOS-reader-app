//
//  BookView.swift
//  MacReader
//
//  Created by Anastasia Ivanova on 13.01.25.
//

import SwiftUI

struct BookView: View {
    let book: ContentView.BookItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let thumbnail = book.thumbnail {
                AsyncImage(url: thumbnail) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            Text(book.title)
                .font(.largeTitle)
                .bold()
            
            Text("Author: \(book.author)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Book Details")
    }
}

#Preview {
    BookView(book: ContentView.BookItem(
        id: "1",
        title: "Sample Book Title",
        author: "Sample Author",
        thumbnail: URL(string: "loading")
    ))
}
