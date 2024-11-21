//
//  AlertConfigView.swift
//  Exposure
//
//  Created by Toby on 1/11/2024.
//

import SwiftUI
import SwiftData
import UserNotifications
import Charts

struct ExposureLogView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query var items: [ExposureItem]

    var body: some View {
        NavigationView {
            List {
                
                if items.filter({!$0.isEmpty}).count == 0 {
                    Section("Welcome") {
                        Text("You will receive random notifications that are supposed to simulate an exposure event. When you open the notification, you'll be taken into the app to record your distress level. Those results will be displayed here.")
                            .disabled(true)
                    }
                }
                
                Section("Past logs") {
                    if items.filter({!$0.isEmpty}).count == 0 {
                        Text("No exposure logs completed yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items.filter({!$0.isEmpty}).sorted(by: { $0.timestamp < $1.timestamp })) { item in
                        NavigationLink {
                            ExposureItemDetail(exposureItem: item)
                        } label: {
                            VStack {
                                HStack {
                                    Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))

                                    Spacer()
                                    
                                    MinimalBarChart(item: item)
                                }
                            }
                        }
                    }.onDelete(perform: deleteLoggedItem)
                }
                
                if items.filter({!$0.isEmpty}).count > 0 {
                    // PDF EXPORT
                    ShareLink(item: exportPDF()) {
                        Label("Save All as PDF", systemImage: "arrow.down.document")
                    }
                }
                
                Section("Upcoming Alerts") {
                    if items.filter({$0.isEmpty}).count == 0 {
                        Button("Tap to schedule future alerts") {
                            withAnimation {
                                scheduleAlerts()
                            }
                        }
                    } else {
                        ForEach(items.filter({$0.isEmpty}).sorted(by: { $0.timestamp < $1.timestamp })) { item in
                            PendingAlertView(item: item)
                        }.onDelete(perform: deleteUpcomingItem)
                    }
                }
                
                if items.filter({$0.isEmpty}).count > 0 {
                    Button("Cancel All Upcoming Alerts") {
                        removeAlerts()
                    }.foregroundStyle(.red)
                }
                
            }
            .navigationTitle("History")
        }
    }
    
    private func scheduleAlerts() {
        requestPermission()
        removeAlerts()
        
        let newItems = appState.scheduleAlerts()
        for item in newItems {
            modelContext.insert(item)
        }
    }
    
    private func removeAlerts() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        withAnimation {
            for currItem in items {
                if currItem.isEmpty {
                    modelContext.delete(currItem)
                }
            }
            
            do {
                try modelContext.save()
            } catch {
                print("uh oh")
            }
        }
    }
    
    private func exportPDF() -> URL {
        
        let numFirstPageItems = 3.0
        let numOtherPageItems = 4.0
        
        let exposures = items.filter({!$0.isEmpty}).sorted(by: { $0.timestamp < $1.timestamp})

        // Configure output URL
        let safeDateString = Date().formatted(date: .numeric, time: .omitted)
                                .replacingOccurrences(of: "/", with: "-")
        let url = URL.documentsDirectory.appending(path: "All Exposure Results - \(safeDateString).pdf")
        
        // set PDF size to A4 @ 200 DPI
        var box = CGRect(x: 0, y: 0, width: 1660, height: 2340)

        // Create the CGContext for PDF
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        // Calculate number of pages (3 items first page, 4 items per page after)
        let numPages = Int(max(ceil(Double(exposures.count + 1)/numOtherPageItems), 1))
                
        for idx in 0..<numPages {
            
            // Start a new PDF page
            pdf.beginPDFPage(nil)
            
            let numItems = idx == 0 ? Int(numFirstPageItems) : Int(numOtherPageItems)
            let range = (idx-1)*numItems+Int(numFirstPageItems) ..< min(idx*numItems+Int(numFirstPageItems), exposures.count)
            
            let renderer = ImageRenderer(content:
                PDFPageView(
                    exposureItems: Array(exposures[range]),
                    pageNum: idx+1,
                    includeHeading: idx == 0
                ).environmentObject(appState)
            )
            
            // Render the SwiftUI view data onto the page
            renderer.render { size, context in
                
                // Place the view in the middle of pdf on x-axis
                let xTranslation = box.size.width / 2 - size.width / 2
                let yTranslation = box.size.height / 2 - size.height / 2
                
                pdf.translateBy(
                    x: xTranslation,
                    y: yTranslation
                )
                
                context(pdf)
            }

            pdf.endPDFPage()
        }
        pdf.closePDF()

        return url
    }
    
    private func deleteLoggedItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let loggedItems = items.filter({!$0.isEmpty})
                modelContext.delete(loggedItems.sorted(by: { $0.timestamp < $1.timestamp })[index])
            }
        }
    }

    private func deleteUpcomingItem(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let upcomingItems = items.filter({$0.isEmpty})
                modelContext.delete(upcomingItems.sorted(by: { $0.timestamp < $1.timestamp })[index])
            }
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success , error in
            if success {
                print("lets go")
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ExposureItem.self, configurations: config)
    
    let _ = container.mainContext.insert(ExposureItem.preview)
    let _ = container.mainContext.insert(ExposureItem.preview)
    
    ExposureLogView()
        .modelContainer(container)
        .environmentObject(AppState())
}

struct MinimalBarChart: View {
    var item: ExposureItem
    var body: some View {
        
        let logData = item.distressDict.sorted(by: <)
        let logDataKeys = Array(item.distressDict.keys).sorted(by: <)
        
        Chart(
            logData, id: \.key
        ) { key, value in
            let index = Int(logDataKeys.indices(of: key).ranges.first!.lowerBound)
            let barColor: Color = index == 0 ? .orange : .teal
            
            BarMark(
                x: .value("Follow Up #", index),
                yStart: .value("Start", 0),
                yEnd: .value("Distress Level", 100),
                width: .fixed(5)
            ).foregroundStyle(.gray.opacity(0.2))
            .clipShape(
                .rect(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 8,
                    topTrailingRadius: 8
                )
            ).position(by: .value("Follow Up #", index))
            
            BarMark(
                x: .value("Follow Up #", index),
                y: .value("Distress Level", max(value, 16)),
                width: .fixed(5)
            ).foregroundStyle(barColor)
            .clipShape(
                .rect(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 8,
                    topTrailingRadius: 8
                )
            )
            
        }.chartPlotStyle { chartContent in
            chartContent
                .background(Color.secondary.opacity(0.0))
                .frame(width: 60, height: 27)
            
        }.chartYScale(
            domain: [0, 100]
        ).chartXScale(
            domain: [0, 6]
        ).chartYAxis {
            //                                        AxisMarks(stroke: StrokeStyle(lineWidth: 0))
        }.chartXAxis {
            //                                        AxisMarks(stroke: StrokeStyle(lineWidth: 0))
        }.padding(.trailing, 4)
    }
}

struct PendingAlertView: View {
    var item: ExposureItem
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        // Alert has already fired, allow user to log exposure
        if Date() > item.timestamp {
            if Date().timeIntervalSince(item.timestamp) <= 60 * 60 * 24 {
                Button {
                    appState.isFollowUp = false
                    appState.currentExposureUUID = item.uuid.uuidString
                    appState.isExposureInputViewPresented = true
    //                ExposureInputView()
                } label: {
                    VStack {
                        HStack {
                            Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Complete Now")
                        }
                    }
                }
            }
            
        // Alert has yet to fire
        } else {
            HStack {
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
                Spacer()
                Text("Pending")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
