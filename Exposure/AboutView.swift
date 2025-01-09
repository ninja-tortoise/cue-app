//
//  AboutView.swift
//  Exposure
//
//  Created by Toby on 9/1/2025.
//

import SwiftUI
import SwiftData
import UserNotifications

struct AboutView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query private var items: [ExposureItem]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        List {
            Text("Hello")
            
            // TODO: Text about how no data is collected
            
            // TODO: Link to GitHub
            // TODO: Link to exposure therapy resources
            // TODO: Link to SUDS information?
            
            // TODO: Link to help lines?
            // TODO: Donation links instead of IAP?
        }
        .navigationTitle("About Cue")
    }
    
}
