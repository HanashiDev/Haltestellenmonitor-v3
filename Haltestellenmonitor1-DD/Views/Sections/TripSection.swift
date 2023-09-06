//
//  TripSection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct TripSection: View {
    var route: Route
    
    var body: some View {
        // TODO: Steig bzw. Gleis überall einfügen
        Section {
            HStack {
                Text("\(route.getStartTimeString()) Uhr")
                Image(systemName: "arrow.forward")
                Text("\(route.getEndTimeString()) Uhr")
                Spacer()
                Text("| \(getTime())")
            }.font(.subheadline)
            
            if route.Interchanges > 0 {
                Text("\(getUmstiege())")
            }
            
            tripView()
        }
    }
    
    @ViewBuilder
    func tripView() -> some View {
        let time: CGFloat = CGFloat(route.getTimeDifference())
        
        GeometryReader { geo in
            HStack {
                ForEach(route.PartialRoutes, id: \.self) { partialRoute in
                    let stopTime = partialRoute.getDuration()
                    let currentTime = CGFloat(100 * stopTime) / time
                    let width = currentTime / 100 * geo.size.width
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(partialRoute.getColor())
                            .frame(width: width, height: 5)
                        Text(partialRoute.getNameShort())
                    }
                }
            }
        }
    }

    func getTime() -> String {
        route.getTimeDifference() == 1 ? "1 Minute" : "\(route.getTimeDifference()) Minuten"
    }
    
    func getUmstiege() -> String {
        route.Interchanges == 1 ? "1 Umstieg" : "\(route.Interchanges) Umstiege"
    }
    
}

struct TripSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TripSection(route: tripTmp.Routes[0])
        }
    }
}
