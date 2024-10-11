//
//  ExporeItemDetail.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//

import SwiftUI
import Charts

struct ExposureItemDetail: View {
    var exposureItem: ExposureItem
    
    var minTime: Double = 0.0
    var maxTime: Double = 0.0
    
    var body: some View {
        VStack {
            
            List {
                Section("ID: \(exposureItem.uuid)") {
                    
                    HStack {
                        Text("Log Date")
                        Spacer()
                        Text("\(exposureItem.timestamp.formatted())")
                    }
                    
                    HStack {
                        Text("Severity")
                        Spacer()
                        Text("\(exposureItem.severity) %")
                            .bold()
                    }
                    
                    HStack {
                        Text("Likelihood")
                        Spacer()
                        Text("\(exposureItem.likelihood) %")
                            .bold()
                    }
                }
                
                Section("Distress Levels") {
                    VStack {
                        HStack {
                            Text("Your Subjective Units of Distress (SUDS) level over time.")
//                                .font(.system(size: 12))
                        }
                        
                        Chart(
                            exposureItem.distressDict.sorted(by: >), id: \.key
                        ) { key, value in
                            
                            BarMark(
                                x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                                y: .value("Distress Level", value),
                                width: .fixed(25)
                            ).foregroundStyle(.mint)
//                                .clipShape(Capsule())
                            
                        }.chartPlotStyle { chartContent in
                            chartContent
                                .background(Color.secondary.opacity(0.0))
                                .frame(height: 240)
                            
                        }.chartYScale(domain: [0, 110])
                        .chartYAxis {
                            AxisMarks(
                                format: Decimal.FormatStyle.Percent.percent.scale(1),
                                position: .leading,
                                values: [0, 20, 40, 60, 80, 100]
                            )
                        }.chartXAxis {
                            AxisMarks(values: .stride(by: .minute, count: 2))
                        }.chartXScale(domain: .automatic(dataType: Date.self) { dates in
                            var initial_dates = exposureItem.distressDict.keys.map({ Date(timeIntervalSince1970: Double($0)!) })
                            initial_dates.sort()
                            
                            let duration = Int(dates.last!.timeIntervalSinceReferenceDate - dates.first!.timeIntervalSinceReferenceDate)
                            
                            let calendar = Calendar.current
                            let earliestDate = calendar.date(byAdding: .second, value: -(duration/3), to: dates.first!)!
                            let latestDate = calendar.date(byAdding: .second, value: (duration/3), to: dates.last!)!
                            
                            initial_dates.append(earliestDate)
                            initial_dates.append(latestDate)
                            initial_dates.sort()
                            
                            dates = initial_dates
                        })
                    }
                }
                
            }
        }
    }
    
//    private func getChartDomain() {
//        
//        ForEach(exposureItem.distressDict.sorted(by: >), id: \.key) { key, value in
//            if Double(key)! < minTime {
//                minTime = Double(key)!
//            }
//        }
//        
//    }
}


struct ExposureItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        ExposureItemDetail(exposureItem: ExposureItem.preview)
    }
}

//#Preview {
//    ExposureItemDetail_Previews()
//}
