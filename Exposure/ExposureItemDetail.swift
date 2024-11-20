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
                DistressBarChart(
                    item: exposureItem,
                    chartFont: .caption,
                    chartAxisLabels: false
                )
                .frame(height: 240)
            }
            
            // MANUAL FOLLOW UP LOG
            if exposureItem.distressDict.count-1 < appState.numberOfFollowUps {
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
//            .foregroundStyle(.blue)
        }
        .navigationTitle("\(exposureItem.timestamp.formatted())")
    }
    
    private func exportPDF() -> URL {
        
        let numFirstPageItems = 3
        let numOtherPageItems = 4
        
        let exposures = [exposureItem]

        // Configure output URL
        let safeDateString = Date().formatted(date: .numeric, time: .omitted)
                                .replacingOccurrences(of: "/", with: "-")
        let url = URL.documentsDirectory.appending(path: "Exposure Results \(safeDateString).pdf")
        
        // set PDF size to A4 @ 200 DPI
        var box = CGRect(x: 0, y: 0, width: 1654, height: 2229)

        // Create the CGContext for PDF
        guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
            return url
        }
        
        // Calculate number of pages (3 items first page, 4 items per page after)
        let numPages = Int(max(ceil(Double((exposures.count + 1)/numOtherPageItems)), 1))
        
        let _ = print(numPages)
        
        for idx in 0..<numPages {
            
            // Start a new PDF page
            pdf.beginPDFPage(nil)
            
            let numItems = idx == 0 ? numFirstPageItems : numOtherPageItems
            let range = (idx-1)*numItems+numFirstPageItems ..< min(idx*numItems+numFirstPageItems, exposures.count)
            
            let _ = print(numItems)
            let _ = print(range)
            
            let renderer = ImageRenderer(content:
                PDFPageView(
                    exposureItems: Array(exposures[range]),
                    includeHeading: idx == 0
                ).environmentObject(appState)
            )
            
            // Render the SwiftUI view data onto the page
            renderer.render { size, context in
                context(pdf)
            }

            pdf.endPDFPage()
        }
        pdf.closePDF()

        return url
    }
}

#Preview {
    ExposureItemDetail(exposureItem: ExposureItem.preview)
        .environmentObject(AppState())
}
