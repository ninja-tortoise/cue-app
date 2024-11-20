//
//  DistressBarChart.swift
//  Exposure
//
//  Created by Toby on 19/11/2024.
//

import SwiftUICore
import SwiftUI
import Charts

struct DistressBarChart: View {
    @StateObject var vm = ViewModel()
    var item: ExposureItem
    var barWidth: CGFloat = 15
    var chartFont: Font = .title3
    var chartAxisLabels: Bool = true
    
    var body: some View {

        let logData = item.distressDict.sorted(by: <)
        if let startTime = logData.first?.key {
            
            Chart(
                logData, id: \.key
            ) { key, value in
                
                if key == startTime {
                    BarMark(
                        x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                        y: .value("Distress Level", value),
                        width: .fixed(barWidth)
                    ).foregroundStyle(.orange)
                        .clipShape(
                            .rect(
                                topLeadingRadius: barWidth/2,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: barWidth/2
                            )
                        )
                    
                } else {
                    BarMark(
                        x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                        y: .value("Distress Level", value),
                        width: .fixed(barWidth)
                    ).foregroundStyle(.teal)
                        .clipShape(
                            .rect(
                                topLeadingRadius: barWidth/2,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: barWidth/2
                            )
                        )
                }
                
            }.chartPlotStyle { chartContent in
                chartContent
                    .background(Color.secondary.opacity(0.0))
                
            }.chartYScale(
                domain: [0, 100]
                
            ).chartYAxis {
                AxisMarks(
                    position: .leading,
                    values: [0, 20, 40, 60, 80, 100]
                ) {
                    AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
                        .font(chartFont)
                }
                
                AxisMarks(
                    values: [0, 20, 40, 60, 80, 100]
                ) {
                    AxisGridLine()
                }
                
            }.chartXScale(domain: .automatic(dataType: Date.self) { dates in
                var initial_dates = item.distressDict.keys.map({ Date(timeIntervalSince1970: Double($0)!) })
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
                AxisMarks(
                    values: .stride(by: .minute, count: vm.xAxisStride, roundLowerBound: true, roundUpperBound: true)
                ) {
                    AxisValueLabel().font(chartFont)
                }
                
                AxisMarks(
                    values: .stride(by: .minute, count: vm.xAxisStride, roundLowerBound: true, roundUpperBound: true)
                ) {
                    AxisGridLine()
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                if chartAxisLabels {
                    Text("Time of Day")
                        .font(chartFont)
                }
            }
            .chartYAxisLabel(position: .leading, alignment: .center) {
                if chartAxisLabels {
                    Text("Subjective Units of Distress (SUDS)")
                        .font(chartFont)
                        .rotationEffect(Angle(degrees: -180))
                    //                .padding(10)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func updateStride() {
//        DispatchQueue.main.async {
            let strideDuration = Double(vm.duration)/60.0/3.0
            vm.xAxisStride = Int(ceil(strideDuration))
//        }
    }
}
