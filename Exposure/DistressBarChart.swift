struct DistressBarChart: View {
    @StateObject private var vm = ViewModel()
    var item: ExposureItem
    var body: some View {

        let logData = item.distressDict.sorted(by: <)
        let startTime = logData.first!.key
        //                        let _ = print(startTime)
        
        Chart(
            logData, id: \.key
        ) { key, value in
            
            if key == startTime {
                BarMark(
                    x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                    y: .value("Distress Level", value),
                    width: .fixed(15)
                ).foregroundStyle(.orange)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 8
                        )
                    )
                
            } else {
                BarMark(
                    x: .value("Time", Date(timeIntervalSince1970: Double(key)!), unit: .second),
                    y: .value("Distress Level", value),
                    width: .fixed(15)
                ).foregroundStyle(.teal)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 8
                        )
                    )
            }
            
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
            AxisMarks(values: .stride(by: .minute, count: vm.xAxisStride, roundLowerBound: true, roundUpperBound: true))
        }
        .padding(.vertical, 10)
    }
    
    private func updateStride() {
        DispatchQueue.main.async {
            let strideDuration = Double(vm.duration)/60.0/3.0
            vm.xAxisStride = Int(ceil(strideDuration))
        }
    }
}