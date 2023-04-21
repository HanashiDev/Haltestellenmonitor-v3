//
//  DepartureRowView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct DepartureRow: View {
    var departure: Departure
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: departure.getIcon())
            VStack(alignment: .leading) {
                Text(departure.getName())
                    .font(.headline)
                    .lineLimit(1)
                HStack {
                    Text("\(departure.getScheduledTime()) Uhr")
                        .font(.subheadline)
                    if (departure.getTimeDifference() > 0) {
                        Text("+\(departure.getTimeDifference())")
                            .font(.subheadline)
                            .foregroundColor(Color.red)
                    } else if (departure.getTimeDifference() < 0) {
                        Text("\(departure.getTimeDifference())")
                            .font(.subheadline)
                            .foregroundColor(Color.green)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("in \(departure.getIn()) min")
                    .font(.subheadline)
                Text("\(departure.getRealTime()) Uhr")
                    .font(.subheadline)
            }
        }
    }
}

struct DepartureRowView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureRow(departure: departureM.Departures[4])
    }
}
