//
//  DepartureRowView.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 18.04.23.
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
        HStack(alignment: .center) {
            Text(service.getIcon())
            
            VStack(alignment: .leading) {
                Text(service.getName())
                    .font(.headline)
                
                    .lineLimit(1)
                HStack {
                    Text("\(service.getScheduledTime()) Uhr")
                    if (service.getTimeDifference() > 0) {
                        Text("+\(service.getTimeDifference())")
                            .foregroundColor(Color.red)
                    } else if (service.getTimeDifference() < 0) {
                        Text("\(service.getTimeDifference())")
                            .foregroundColor(Color.green)
                    }
                    Spacer()
                    Text("\(service.getRealTime()) Uhr")
                }
                .font(.subheadline)
                
                HStack {
                    if (service.plannedBay != "") {
                        Text(service.getPlatForm())
                            .font(.footnote)
                    }
                    Spacer()
                    /*if departure.State == "Cancelled" {
                        Text("Halt fällt aus")
                            .foregroundColor(Color.red)
                    } else {*/
                        Text("in \(departureBinding.inMinute) min")
                    //}
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
