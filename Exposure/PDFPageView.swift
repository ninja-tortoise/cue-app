//
//  PDFPageView.swift
//  Exposure
//
//  Created by Toby on 19/11/2024.
//

import SwiftUI
import Charts

struct PDFPageView: View {
    @EnvironmentObject var appState: AppState
    var exposureItems: [ExposureItem]
    var pageNum: Int = 1
    
    // Default to A4 size
    var width: CGFloat = 1560
    var height: CGFloat = 2240
    var includeHeading = true
    
    var titleSize: CGFloat = 64
    var subtitleSize: CGFloat = 36
    var headingSize: CGFloat = 30
    var bodySize: CGFloat = 24
    var dataPointSize: CGFloat = 24
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Heading
            if includeHeading {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Exposure Log")
                            .font(.system(size: titleSize))
                            .bold()
                        
                        Text("Exported on \(Date().formatted(date: .long, time: .shortened))")
                            .font(.system(size: subtitleSize))
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Feared Outcome:")
                                    .font(.system(size: bodySize))
                                    .bold()
                                Text("Post-Exposure Reminder:")
                                    .font(.system(size: bodySize))
                                    .bold()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text(appState.fearedOutcome.isEmpty ? "N/A" : appState.fearedOutcome)
                                    .font(.system(size: bodySize))
                                
                                Text(appState.postAlertReminder.isEmpty ? "N/A" : appState.postAlertReminder)
                                    .font(.system(size: bodySize))
                            }
                            .padding(.leading, 30)
                        }
                        .padding(.top, 30)
                    }
                    Spacer()
                }
                .padding(.top, 0)
                .padding(.bottom, 80)
            }
            
            // DISTRESS GRAPH
            ForEach(exposureItems) { exposureItem in
                SingleLogPDFView(
                    exposureItem: exposureItem,
                    width: width,
                    height: height,
                    titleSize: titleSize,
                    subtitleSize: subtitleSize,
                    headingSize: headingSize,
                    bodySize: bodySize,
                    dataPointSize: dataPointSize
                )
            }
            
            // Fill rest of the vertical space to top-align
            Spacer()
            
            HStack {
                Text("Data collected and exported using the Exposure Buddy app for iOS.")
//                    .italic()
//                    .foregroundStyle(.gray)
                Spacer()
                Text("Page \(pageNum)")
            }
        }
        .frame(width: width, height: height)
        .background(Color.white)
        .padding(width/30)
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    var state = AppState()
    let _ = state.fearedOutcome = "Lorem ipsum dolor sit amet"
    let _ = state.postAlertReminder = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    
    PDFPageView(
        exposureItems: Array(ExposureItem.previews[0..<3])
//        exposureItems: Array(ExposureItem.previews[0..<4]),
//        includeHeading: false
    )
    .environmentObject(state)
}

struct SingleLogPDFView: View {
    @EnvironmentObject var appState: AppState
    var exposureItem: ExposureItem
    
    // Default to A4 size
    var width: CGFloat = 1560
    var height: CGFloat = 2240
    
    var titleSize: CGFloat = 64
    var subtitleSize: CGFloat = 36
    var headingSize: CGFloat = 30
    var bodySize: CGFloat = 24
    var dataPointSize: CGFloat = 24
    
    var body: some View {
        VStack {
            HStack {
                Text(exposureItem.timestamp.formatted(date: .numeric, time: .shortened))
                    .font(.system(size: headingSize))
                    .bold()
                    .padding(.leading, 20)
                Spacer()
            }
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            
                            // Title Column
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Severity:")
                                    .font(.system(size: bodySize))
                                    .bold()
                                Text("Likelihood:")
                                    .font(.system(size: bodySize))
                                    .bold()
                                Text("Check In Interval:")
                                    .font(.system(size: bodySize))
                                    .bold()
                            }
                            
                            Spacer()
                            
                            // Raw Value Column
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("\(exposureItem.severity) %")
                                    .font(.system(size: bodySize))
                                Text("\(exposureItem.likelihood) %")
                                    .font(.system(size: bodySize))
                                Text("\(appState.followUpInterval) seconds")
                                    .font(.system(size: bodySize))
                            }
                        }.padding(.bottom, 20)
                        
//                        HStack {
//                            Text("Start & End Alerts")
//                                .font(.system(size: bodySize))
//                                .bold()
//                            Spacer()
//                            Text("SUDS")
//                                .font(.system(size: bodySize))
//                                .bold()
//                        }
//                        
//                        // List all data points
//                        if let startTime = exposureItem.distressDict.keys.sorted().first {
//                            
//                            HStack(alignment: .center) {
//                                
//                                let sudsVal = exposureItem.distressDict[startTime] ?? -1
//                                let sudsValStr = sudsVal == -1 ? "N/A" : "\(sudsVal)"
//                                let timeOfEntry = Date(timeIntervalSince1970: Double(startTime)!)
//                                let timeOfEntryStr = timeOfEntry.formatted(date: .omitted, time: .shortened)
//                                
//                                Circle()
//                                    .fill(.orange)
//                                    .frame(width: 12, height: 12)
//                                    .padding(.leading, 20)
//                                
//                                Text("Initial Exposure")
//                                    .font(.system(size: dataPointSize))
//                                    .foregroundStyle(.orange)
//                                    .bold()
//                                
//                                Text(timeOfEntryStr)
//                                    .font(.system(size: dataPointSize))
//                                    .padding(.leading, 10)
//                                
//                                Spacer()
//                                
//                                Text(sudsValStr + " %")
//                                    .font(.system(size: dataPointSize))
//                                    .foregroundStyle(.orange)
//                                    .bold()
//                                
//                            }
//                        }
//                        
//                        if let endTime = exposureItem.distressDict.keys.sorted().last {
//                            
//                            HStack(alignment: .center) {
//                                
//                                let sudsVal = exposureItem.distressDict[endTime] ?? -1
//                                let sudsValStr = sudsVal == -1 ? "N/A" : "\(sudsVal)"
//                                let timeOfEntry = Date(timeIntervalSince1970: Double(endTime)!)
//                                let timeOfEntryStr = timeOfEntry.formatted(date: .omitted, time: .shortened)
//                                
//                                Circle()
//                                    .fill(.teal)
//                                    .frame(width: 12, height: 12)
//                                    .padding(.leading, 20)
//                                
//                                Text("Last Check In ")
//                                    .font(.system(size: dataPointSize))
//                                    .foregroundStyle(.teal)
//                                    .bold()
//                                
//                                Text(timeOfEntryStr)
//                                    .font(.system(size: dataPointSize))
//                                    .padding(.leading, 10)
//                                
//                                Spacer()
//                                
//                                Text(sudsValStr + " %")
//                                    .font(.system(size: dataPointSize))
//                                    .foregroundStyle(.teal)
//                                    .bold()
//                                
//                            }
//                        }
                        
                        
                        // NOTES
                        HStack {
                            Text("Observations")
                                .font(.system(size: bodySize))
                                .bold()
                        }.padding(.top, 10)
                        
                        
                        ObservationsView(exposureItem: exposureItem,
                                         dataPointSize: dataPointSize)
                        
                    }
                    .padding(.trailing, 120)
                    .padding(.leading, 40)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    VStack {
                        Text("Level of Distress Over Time")
                            .font(.system(size: dataPointSize))
                            .bold()
                        DistressBarChart(item: exposureItem, barWidth: 30)
                            .frame(width: width/2)
                            .padding(.trailing, 40)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 30)
                }
            }
            .background(.gray.opacity(0.08))
            .cornerRadius(30)
            .frame(height: height/4.4)
            
//            HStack {
//                Text("Alert ID: \(exposureItem.uuid)")
//                    .bold()
//                    .foregroundStyle(.gray)
//                Spacer()
//            }.padding(.leading, 20)
        }
        .padding(.bottom, 50)
    }
}

struct ObservationsView: View {
    @EnvironmentObject var appState: AppState
    var exposureItem: ExposureItem
    var dataPointSize: CGFloat = 24
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            
            // List all data points
            let sortedTimes = Array(exposureItem.distressDict.keys.sorted())
            let sortedDictValues = exposureItem.distressDict.sorted(by: <)
            
            let dateFormatter = DateFormatter()
            let _ = dateFormatter.dateFormat = "hh:mm a"
            
            ForEach(Array(exposureItem.notes.enumerated()), id: \.element) { index, note in
                
                let sudsVal = sortedDictValues[index].value
                let sudsValStr = sudsVal == -1 ? "N/A" : "\(sudsVal)"
                
                HStack(alignment: .top) {
                    
                    // SUDS
                    HStack{
                        Text("\(sudsValStr)%")
    //                        .foregroundStyle(.secondary)
    //                        .font(.system(size: dataPointSize))
                            .foregroundStyle(index == 0 ? .orange : .teal)
                            .bold()
                        Spacer()
                    }
                    .frame(minWidth: 60, maxWidth: 60)
                    
                    // TIME
                    HStack{
                        Text("\(dateFormatter.string(from: Date(timeIntervalSince1970: Double(sortedTimes[index])!)))")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(minWidth: 86, maxWidth: 86)
                    
                                    
                    // NOTES
                    HStack{
                        if note.isEmpty {
                            Text("-")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(note)
                                .lineLimit(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
