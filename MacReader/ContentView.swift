//
//  ContentView.swift
//  MacReader
//
//  Created by Anastasia Ivanova on 05.01.25.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext //  pulls the managedObjectContext from the environment & gives us access to the Core Data context
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onAppear(){
                    print("Managed Object Context: \(viewContext)")
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
