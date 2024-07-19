//
//  DepartureRow.swift
//  WatchMonitor Watch App
//
//  Created by Peter Lohse on 22.04.23.
//

import SwiftUI

struct DepartureRow: View {
    var service: Service
    
    @ObservedObject private var departureBinding: DepartureBinding
    
    init(service: Service) {
        self.service = service
        
        self.departureBinding = DepartureBinding(inMinute: service.getIn())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(service.getName())
                .lineLimit(1)
            HStack {
                Text(service.getScheduledTime())
                if (service.getTimeDifference() > 0) {
                    Text("+\(service.getTimeDifference())")
                        .foregroundColor(Color.red)
                } else if (service.getTimeDifference() < 0) {
                    Text("\(service.getTimeDifference())")
                        .foregroundColor(Color.green)
                }
                Spacer()
                Text(service.getRealTime())
            }
            .font(.footnote)
            HStack {
                if (service.plannedBay != "") {
                    Text(service.getPlatForm())
                }
                Spacer()
                /*if service.State == "Cancelled" {
                    Text("Halt fällt aus")
                        .foregroundColor(Color.red)
                } else {*/
                    Text("in \(departureBinding.inMinute) min")
                //}
            }
            .font(.footnote)
        }
    }
}

/*struct DepartureRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            DepartureRow(departure: departureM.Departures[4])
        }
    }
}*/
