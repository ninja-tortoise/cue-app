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
    
    var width: CGFloat = 1654
    var height: CGFloat = 2229
    var includeHeading = true
    
    var titleSize: CGFloat = 64
    var subtitleSize: CGFloat = 36
    var headingSize: CGFloat = 32
    var bodySize: CGFloat = 22
    var dataPointSize: CGFloat = 22
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Heading
            if includeHeading {
                HStack {
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
                .padding(.top, 20)
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
//        exposureItems: Array(ExposureItem.previews[3..<min(6, ExposureItem.previews.count)]),
//        includeHeading: false
    )
    .environmentObject(state)
}

struct SingleLogPDFView: View {
    @EnvironmentObject var appState: AppState
    var exposureItem: ExposureItem
    
    // Establish default sizes
    var width: CGFloat = 1654
    var height: CGFloat = 2229
    var titleSize: CGFloat = 70
    var subtitleSize: CGFloat = 36
    var headingSize: CGFloat = 48
    var bodySize: CGFloat = 32
    var dataPointSize: CGFloat = 26
    
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
                                Text("Follow Up Interval:")
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
                        
                        Text("SUDS Levels")
                            .font(.system(size: dataPointSize))
                            .bold()
                        
                        // List all data points
                        let startTime = exposureItem.distressDict.keys.sorted().first!
                        ForEach(exposureItem.distressDict.keys.sorted(), id: \.self) { key in
                            HStack(alignment: .center) {
                                let sudsVal = exposureItem.distressDict[key] ?? -1
                                let sudsValStr = sudsVal == -1 ? "N/A" : "\(sudsVal)"
                                let timeOfEntry = Date(timeIntervalSince1970: Double(key)!)
                                var timeOfEntryStr = timeOfEntry.formatted(date: .omitted, time: .shortened)
                                
                                if startTime == key {
                                    Circle()
                                        .fill(.orange)
                                        .frame(width: 12, height: 12)
                                        .padding(.leading, 30)
                                    let _ = timeOfEntryStr = timeOfEntryStr + "  (Initial Exposure)"
                                } else {
                                    Circle()
                                        .fill(.teal)
                                        .frame(width: 12, height: 12)
                                        .padding(.leading, 30)
                                    let _ = timeOfEntryStr = timeOfEntryStr + "  (Follow Up)"
                                }
                                
                                Text(timeOfEntryStr)
                                    .font(.system(size: dataPointSize))
                                    .padding(.leading, 10)
                                
                                Spacer()
                                
                                Text(sudsValStr + " %")
                                    .font(.system(size: dataPointSize))
                            }
                        }
                        //                            .padding(.top, 20)
                    }
                    .padding(.trailing, 120)
                    .padding(.leading, 40)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    VStack {
                        Text("Level of Distress Over Time")
                            .font(.system(size: dataPointSize))
                            .bold()
                        //                                .foregroundStyle(.black.opacity(0.7))
                        DistressBarChart(item: exposureItem, barWidth: 30)
                            .frame(width: width/2)
                            .padding(.trailing, 40)
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 30)
                }
            }
            .background(.gray.opacity(0.1))
            .cornerRadius(30)
            .frame(height: height/5)
            
            HStack {
                Text("Alert ID: \(exposureItem.uuid)")
                    .bold()
                    .foregroundStyle(.gray)
                Spacer()
            }.padding(.leading, 20)
        }
        .padding(.bottom, 50)
    }
}
