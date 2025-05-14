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
                Text("\(vm.route.getStartTimeString()) Uhr")
                    .accessibilityLabel("Abfahrt \(vm.route.getStartTimeString()) Uhr")
                Image(systemName: "arrow.forward")
                    .accessibilityHidden(true)
                Text("\(vm.route.getEndTimeString()) Uhr")
                    .accessibilityLabel(Text("Ankunft \(vm.route.getEndTimeString()) Uhr"))

                Spacer()

                Text("| \(vm.getTime())")
                    .foregroundColor(.gray)
                    .accessibilityLabel("Dauer: \(vm.getTime())")


                if vm.route.Interchanges > 0 {
                    Text("| \(vm.route.Interchanges)")
                        .foregroundColor(.gray)
                        .accessibilityLabel("\(vm.route.Interchanges) \(vm.route.Interchanges == 1 ? "Umstieg" : "Umstiege")")
                    Image(systemName: "shuffle")
                        .foregroundColor(.gray)
                        .accessibilityHidden(true)

                }
            }
            .font(.subheadline)
            .accessibilityElement(children: .combine)

            DisclosureGroup {
                ForEach(vm.routesWithWaitingTimeUnder2Min, id: \.self) { partialRoute in
                    if partialRoute.Mot.type == "InsertedWaiting" && partialRoute.getDuration() > 0 {
                        PartialRouteRowWaitingTime(time: partialRoute.getDuration(), text: partialRoute.getName())
                    }
                    if partialRoute.RegularStops == nil {
                        if partialRoute.getDuration() == 0 {
                            let tup = vm.getDuration(partialRoute)
                            if tup.0 > 0 {
                                PartialRouteRowWaitingTime(time: tup.0, text: tup.1)
                            }
                        } else {
                            PartialRouteRow(partialRoute: partialRoute)
                        }
                    } else {
                        if partialRoute.Mot.type != "InsertedWaiting" {
                            // actual tram/bus etc parts
                            DisclosureGroup {
                                ForEach(partialRoute.RegularStops ?? [], id: \.self) { regularStop in
                                    ZStack {
                                        NavigationLink(value: regularStop.getStop() ?? stops[0]) {
                                            EmptyView()
                                        }
                                        .opacity(0.0)
                                        .buttonStyle(.plain)

                                        RegularStopRow(regularStop: regularStop, isFirst: partialRoute.RegularStops?.first?.DataId == regularStop.DataId)
                                    }
                                }
                            } label: {
                                PartialRouteRow(partialRoute: partialRoute)
                            }}
                    }
                }
            }
        label: { tripView() }
        }.accessibilityHint("Abschnitte der Route")
    }

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
                        Text(routeEntry.name)
                            .foregroundColor(.customGray)
                            .font(.footnote)
                            .frame(width: routeEntry.width, height: 15)
                            .accessibilityLabel(routeEntry.name != getIcon(motType: .Walking) ? "Linie \(routeEntry.name)" : "Fußweg")
                    }.padding(0)
                }
            }.frame(width: geo.size.width)
        }
    }
}

struct TripSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TripSection(vm: TripSectionViewModel(route: tripTmp.Routes[0]))
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
