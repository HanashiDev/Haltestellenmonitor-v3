//
//  DepartureRowView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
//

import SwiftUI

struct DepartureRow: View {
    var stopEvent: StopEvent
    
    @ObservedObject private var departureBinding: DepartureBinding
    
    init(stopEvent: StopEvent) {
        self.stopEvent = stopEvent
        
        self.departureBinding = DepartureBinding(inMinute: stopEvent.getIn())
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(stopEvent.getIcon())
            
            VStack(alignment: .leading) {
                Text(stopEvent.getName())
                    .font(.headline)
                
                    .lineLimit(1)
                HStack {
                    Text("\(stopEvent.getScheduledTime()) Uhr")
                    if (stopEvent.getTimeDifference() > 0) {
                        Text("+\(stopEvent.getTimeDifference())")
                            .foregroundColor(Color.red)
                    } else if (stopEvent.getTimeDifference() < 0) {
                        Text("\(stopEvent.getTimeDifference())")
                            .foregroundColor(Color.green)
                    }
                    Spacer()
                    Text("\(stopEvent.getRealTime()) Uhr")
                }
                .font(.subheadline)
                
                HStack {
                    if (stopEvent.ThisCall.PlannedBay != nil || stopEvent.ThisCall.EstimatedBay != nil) {
                        Text(stopEvent.getPlatForm())
                            .font(.footnote)
                    }
                    Spacer()
                    if stopEvent.Cancelled == "true" {
                        Text("Halt fällt aus")
                            .foregroundColor(Color.red)
                    } else {
                        Text("in \(departureBinding.inMinute) min")
                    }
                }
                .font(.subheadline)
            }
        }
    }
}

/*struct DepartureRowView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureRow(departure: departureM.Departures[4])
    }
}*/
