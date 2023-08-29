//
//  DepartureRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct DepartureRow: View {
    var departure: Departure
    
    @ObservedObject private var departureBinding: DepartureBinding
    
    init(departure: Departure) {
        self.departure = departure
        
        self.departureBinding = DepartureBinding(inMinute: departure.getIn())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(departure.getName())
                .lineLimit(1)
            HStack {
                Text(departure.getScheduledTime())
                if (departure.getTimeDifference() > 0) {
                    Text("+\(departure.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (departure.getTimeDifference() < 0) {
                    Text("\(departure.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(departure.getRealTime())
            }
            .font(.footnote)
            HStack {
                if (departure.Platform != nil) {
                    Text(departure.getPlatForm())
                }
                Spacer()
                if departure.State == "Cancelled" {
                    Text("Halt fällt aus")
                        .foregroundColor(Color.red)
                } else {
                    Text("in \(departureBinding.inMinute) min")
                }
            }
            .font(.footnote)
        }
    }
}

struct DepartureRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DepartureRow(departure: departureM.Departures[4])
        }
    }
}
