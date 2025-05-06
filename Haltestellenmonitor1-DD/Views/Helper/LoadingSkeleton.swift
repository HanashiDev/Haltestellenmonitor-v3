//
//  LoadingSkeleton.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 06.05.25.
//  inspired by https://medium.com/@thiagorodriguescenturion/stop-using-progressview-custom-skeleton-loading-in-swiftui-83682ca7a13e
//
import SwiftUI

struct GradientMask: View {
    let phase: CGFloat
    let centerColor = Color.black.opacity(0.5)
    let edgeColor = Color.black.opacity(1)

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                gradient: Gradient(
                    stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]),
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 1, y: 0.5)
            )
            .rotationEffect(Angle(degrees: 45))
            .offset(x: -geometry.size.width, y: -geometry.size.height)
            .frame(width: geometry.size.width * 3, height: geometry.size.height * 3)
        }
    }
}

struct AnimatedMask: ViewModifier, Animatable {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        content
            .mask(
                GradientMask(phase: phase)
                    .scaleEffect(3)
            )
    }
}

struct ShimmeringModifer: ViewModifier {
    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

public extension View {
    func skeleton<S>(_ shape: S? = nil as Rectangle?, isLoading: Bool = true) -> some View where S: Shape {
        guard isLoading else {
            return AnyView(self)
        }
        let fillColor: Color = .gray.opacity(0.3)
        let shape = AnyShape(shape ?? Rectangle() as! S)

        return AnyView(
            opacity(0)
                .overlay(shape.fill(fillColor))
                .shimmering()
            )
    }

    func shimmering() -> some View {
        modifier(ShimmeringModifer())
    }
}
