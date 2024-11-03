//
//  ExporeItemDetail.swift
//  Exposure
//
//  Created by Toby on 11/10/2024.
//

import SwiftUI
import Charts

class ViewModel: ObservableObject {
   @Published var xAxisStride: Int = 2
   @Published var duration: Int = 0
}

struct ExposureItemDetail: View {
    @StateObject private var vm = ViewModel()
    
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
                }
                
                Section("Distress Levels") {
                    VStack {
                        HStack {
                            Text("Your Subjective Units of Distress (SUDS) level over time.")
//                                .font(.system(size: 12))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        
                        Chart(
                            exposureItem.distressDict.sorted(by: >), id: \.key
                        ) { key, value in
                            
                            BarMark(
                                x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                                y: .value("Distress Level", value),
                                width: .fixed(15)
                            ).foregroundStyle(.mint)
                            
                        }.chartPlotStyle { chartContent in
                            chartContent
                                .background(Color.secondary.opacity(0.0))
                                .frame(height: 240)
                            
                        }.chartYScale(
                            domain: [0, 110]
                            
                        ).chartYAxis {
                            AxisMarks(
                                format: Decimal.FormatStyle.Percent.percent.scale(1),
                                position: .leading,
                                values: [0, 20, 40, 60, 80, 100]
                            )
                            
                        }.chartXScale(domain: .automatic(dataType: Date.self) { dates in
                            var initial_dates = exposureItem.distressDict.keys.map({ Date(timeIntervalSince1970: Double($0)!) })
                            initial_dates.sort()
                            
                            let duration = Int(dates.last!.timeIntervalSinceReferenceDate - dates.first!.timeIntervalSinceReferenceDate)
                            
                            DispatchQueue.main.async {
                                vm.duration = duration
                                updateStride()
                            }
                            
                            
                            let calendar = Calendar.current
                            let earliestDate = calendar.date(byAdding: .second, value: -(duration/10), to: dates.first!)!
                            let latestDate = calendar.date(byAdding: .second, value: (duration/10), to: dates.last!)!
                            
                            initial_dates.append(earliestDate)
                            initial_dates.append(latestDate)
                            initial_dates.sort()
                            
                            dates = initial_dates
                        }).chartXAxis {
                            AxisMarks(values: .stride(by: .minute, count: vm.xAxisStride, roundLowerBound: true, roundUpperBound: true))
                        }
                        .padding(.bottom, 12)
                    }
                }
                
                Button("Export as PDF") {
                    exportPDF()
                }.foregroundStyle(.blue)
            }
        }
    }
    
    private func updateStride() {
        DispatchQueue.main.async {
            let strideDuration = Double(vm.duration)/60.0/3.0
            vm.xAxisStride = Int(ceil(strideDuration))
        }
        
    }
    
    private func exportPDF() {
        
    }
}


struct ExposureItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        ExposureItemDetail(exposureItem: ExposureItem.preview)
    }
}

//#Preview {
//    ExposureItemDetail_Previews()
//}
