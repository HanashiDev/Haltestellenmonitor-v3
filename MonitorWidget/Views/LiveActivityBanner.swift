//
//  LiveActivityBanner.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 10.06.25.
//

import SwiftUI
import WidgetKit

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

struct LiveActivityBanner: View {
    let context: ActivityViewContext<TripAttributes>

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(context.attributes.getIcon())
                Text("\(context.attributes.publishedLineName) \(context.attributes.destinationText)")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text("\(context.state.getScheduledTime()) Uhr")
                    .font(.footnote)
                    .opacity(0.6)
                if context.state.getTimeDifference() > 0 {
                    if #available(iOS 17.0, *) {
                        Text("+\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                            .opacity(0.8)
                            .contentTransition(.numericText(value: Double(context.state.getTimeDifference())))
                    } else {
                        Text("+\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                            .opacity(0.8)
                            .contentTransition(.numericText())
                    }
                } else if context.state.getTimeDifference() < 0 {
                    if #available(iOS 17.0, *) {
                        Text("\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.green)
                            .opacity(0.8)
                            .contentTransition(.numericText(value: Double(context.state.getTimeDifference())))
                    } else {
                        Text("\(context.state.getTimeDifference())")
                            .font(.footnote)
                            .foregroundColor(Color.green)
                            .opacity(0.8)
                            .contentTransition(.numericText())
                    }
                }
            }
            Spacer()

            HStack {
                Text(context.attributes.name)
                    .lineLimit(1)
                Spacer()
                Text("\(context.state.getRealTime()) Uhr")
                    .contentTransition(.numericText())
            }
            .font(.subheadline)
            ProgressView(value: context.attributes.getProgress(context.state))
                .progressViewStyle(CustomProgressBar())
                .padding(.horizontal, 5)

            if !context.state.done {
                HStack {
                    Spacer()
                    if #available(iOS 17.0, *) {
                        Text("in \(context.state.getIn()) min")
                            .contentTransition(.numericText(value: Double(context.state.getIn())))
                    } else {
                        Text("in \(context.state.getIn()) min")
                            .contentTransition(.numericText(countsDown: true))
                    }

                    Spacer()
                }
                .frame(height: 15) // prevent shifting when done
            }}
    }
}

struct CustomProgressBar: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let progress = configuration.fractionCompleted ?? 0.0
            let lineHeight: CGFloat = 4
            let dotSize: CGFloat = 15

            ZStack(alignment: .leading) {
                // Background dashed line for remaining progress
                Line()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: lineHeight - 1, lineCap: .round, dash: [8, 12]))
                    .frame(width: width, height: dotSize)

                // Completed progress
                Line()
                    .stroke(style: StrokeStyle(lineWidth: lineHeight + 2, lineCap: .round))
                    .fill((progress == 1 ? Color.green : Color.blue))
                    .frame(width: width * CGFloat(progress), height: lineHeight)
                    .animation(.none, value: progress)

                if progress == 1 {
                    Circle()
                        .fill(Color.green)
                        .frame(width: dotSize, height: dotSize)
                        .offset(x: width - (dotSize / 2))
                    Image(systemName: "checkmark")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: dotSize / 2, height: dotSize / 2)
                        .offset(x: width - (dotSize / 4))
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: dotSize, height: dotSize)
                        .offset(x: width - (dotSize / 2))
                }
            }
            .frame(width: width)
        }
    }
}

@available(iOS 18.0, *)
#Preview("Banner & Watch", as: .content, using: TripAttributes.preview) {
    MonitorWidgetLiveActivity()
} contentStates: {
    TripAttributes.ContentState.initial
    TripAttributes.ContentState.in_progress
    TripAttributes.ContentState.complete
}
