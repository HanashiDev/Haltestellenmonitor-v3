//
//  TripSection.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.04.23.
//

import SwiftUI

struct TripSection: View {
    var vm: TripSectionViewModel

    var body: some View {
        Section {
            HStack {
                Text("\(vm.journey.getStartTimeString()) Uhr")
                    .accessibilityLabel("Abfahrt \(vm.journey.getStartTimeString()) Uhr")
                Image(systemName: "arrow.forward")
                    .accessibilityHidden(true)
                Text("\(vm.journey.getEndTimeString()) Uhr")
                    .accessibilityLabel(Text("Ankunft \(vm.journey.getEndTimeString()) Uhr"))

                Spacer()

                Text("| \(vm.getTime())")
                    .monospacedDigit()
                    .foregroundColor(.gray)
                    .accessibilityLabel("Dauer: \(vm.getTime())")

                if vm.journey.interchanges > 0 {
                    Text("| \(vm.journey.interchanges)")
                        .foregroundColor(.gray)
                        .accessibilityLabel(vm.getAccessibilityInterchangesString())
                    Image(systemName: "shuffle")
                        .foregroundColor(.gray)
                        .accessibilityHidden(true)

                }
            }
            .font(.subheadline)
            .accessibilityElement(children: .combine)

            DisclosureGroup {
                ForEach(vm.routesWithWaitingTimeUnder2Min, id: \.self) { tripLeg in
                    if tripLeg.isInsertedWaiting() && tripLeg.duration > 0 {
                        InterTripLegWaitingRow(time: tripLeg.duration / 60, text: tripLeg.getName())
                    }
                    if tripLeg.stopSequence == nil {
                        if tripLeg.duration == 0 {
                            let tup = vm.getDuration(tripLeg)
                            if tup.0 > 0 {
                                InterTripLegWaitingRow(time: tup.0, text: tup.1)
                            }
                        } else {
                            TripLegRow(tripLeg: tripLeg)
                        }
                    } else {
                        if !tripLeg.isInsertedWaiting() {
                            // actual tram/bus etc parts
                            DisclosureGroup {
                                ForEach(tripLeg.stopSequence!, id: \.self) { stopSequenceItem in
                                    ZStack {
                                        NavigationLink(value: stopSequenceItem.getStop() ?? stops[0]) {
                                            EmptyView()
                                        }
                                        .opacity(0.0)
                                        .buttonStyle(.plain)

                                        StopSequenceRow(stop: stopSequenceItem, isFirst: tripLeg.stopSequence?.first?.id == stopSequenceItem.id)
                                    }
                                }
                            } label: {
                                TripLegRow(tripLeg: tripLeg)
                            }
                        }
                    }
                }
            }
        label: { tripView() }
        }.accessibilityHint("Abschnitte der Route")
    }

    /// Horizontal Bar displaying trip legs
    @ViewBuilder
    func tripView() -> some View {
        GeometryReader { geo in
            HStack(spacing: 0) {

                ForEach(vm.getRouteColoredBars(geo.size.width - 10), id: \.self.nr) { routeEntry in
                    VStack {
                        if routeEntry.name.isEmpty {
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                .foregroundColor(.customGray.opacity(0.7))
                                .frame(width: routeEntry.width, height: 5)
                                .offset(y: 2.5)
                                .accessibilityHidden(true)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(routeEntry.color)
                                .frame(width: routeEntry.width, height: 5)
                                .accessibilityHidden(true)
                        }
                        routeEntry.getNameText()
                            .foregroundColor(.customGray)
                            .font(.footnote)
                            .frame(width: routeEntry.width, height: 15)
                            .accessibilityLabel(routeEntry.name != getIconStandard(motType: .Walking) ? "Linie \(routeEntry.name)" : "Fußweg")
                    }.padding(0)
                }
            }.frame(width: geo.size.width)
        }
    }
}

 struct TripSection_Previews: PreviewProvider {
     static var previews: some View {
         VStack {
             TripSection(vm: TripSectionViewModel(journey: tripTmp.journeys[0]))
         }
     }
 }

struct Line: Shape {
    var y2: CGFloat = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: y2))
        return path
    }
}
