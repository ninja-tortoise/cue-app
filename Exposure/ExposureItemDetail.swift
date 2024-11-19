//
//  ExporeItemDetail.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//

import SwiftUI

class ViewModel: ObservableObject {
   @Published var xAxisStride: Int = 3
   @Published var duration: Int = 0
}

struct ExposureItemDetail: View {
    @EnvironmentObject var appState: AppState

    var exposureItem: ExposureItem
    
    var body: some View {
        List {
            
            // DISTRESS GRAPH
            Section("Distress Levels") {
                HStack {
                    Text("Your Subjective Units of Distress (SUDS) level over time.")
                }
                .padding(.vertical, 4)
                DistressBarChart(item: exposureItem)
                    .frame(height: 240)
            }
            
            // MANUAL FOLLOW UP LOG
            if exposureItem.distressDict.count-1 <= appState.numberOfFollowUps {
                Button {
                    appState.isFollowUp = true
                    appState.currentExposureUUID = exposureItem.uuid.uuidString
                    appState.isExposureInputViewPresented = true
                } label: {
                    VStack {
                        HStack {
                            Text("Log a follow up now")
                        }
                    }
                }
            }
            
            // ITEM DETAILS
            Section("ID: \(exposureItem.uuid)") {
                
                // SEVERITY
                HStack {
                    Text("Severity")
                    Spacer()
                    switch exposureItem.severity {
                    case 0:
                        Text("Nil")
                    case let x where x <= 25:
                        Text("Low")
                    case let x where x <= 50:
                        Text("Moderate")
                    case let x where x <= 100:
                        Text("High")
                    case 100:
                        Text("Certain")
                    default:
                        Text("\(exposureItem.severity)%")
                    }
                }
                
                // LIKELIHOOD
                HStack {
                    Text("Likelihood")
                    Spacer()
                    switch exposureItem.likelihood {
                    case 0:
                        Text("Nil")
                    case let x where x <= 25:
                        Text("Low")
                    case let x where x <= 50:
                        Text("Moderate")
                    case let x where x <= 100:
                        Text("High")
                    case 100:
                        Text("Certain")
                    default:
                        Text("\(exposureItem.likelihood)%")
                    }
                }
                
                // FOLLOW UP COUNT
                HStack {
                    Text("Follow Ups")
                    Spacer()
                    Text("\(exposureItem.distressDict.count-1)/\(appState.numberOfFollowUps)")
                }
                
                // DATE
                HStack {
                    Text("Log Date")
                    Spacer()
                    Text("\(exposureItem.timestamp.formatted())")
                }
            }
            
            // PDF EXPORT
            ShareLink(item: exportPDF()) {
                Label("Save as PDF", systemImage: "arrow.down.document")
            }
                .foregroundStyle(.blue)
        }
    }
    
    private func exportPDF() -> URL {
        // Render Hello World with some modifiers
        let renderer = ImageRenderer(content: PDFPageView(exposureItem: exposureItem))

        // Save it to our documents directory
        let safeDateString = exposureItem.timestamp.formatted(date: .numeric, time: .omitted)
                                .replacingOccurrences(of: "/", with: "-")
        let url = URL.documentsDirectory.appending(path: "Exposure Results \(safeDateString).pdf")

        // Start the rendering process
        renderer.render { size, context in
            
            // PDF is A4 size @ 200 DPI
            var box = CGRect(x: 0, y: 0, width: 1654, height: 2229)

            // Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }

            // Start a new PDF page
            pdf.beginPDFPage(nil)

            // Render the SwiftUI view data onto the page
            context(pdf)

            // End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
        }

        return url
    }
}

#Preview {
    ExposureItemDetail(exposureItem: ExposureItem.preview)
        .environmentObject(AppState())
}
