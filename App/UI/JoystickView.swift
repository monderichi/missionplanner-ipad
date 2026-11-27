// REA Parity Source: MissionPlanner Joystick setup (on-screen equivalent of the two physical sticks).

import SwiftUI

/// One circular thumbstick. `value` is -1...1 on both axes with +y up, and springs back to 0 on release.
struct JoystickPad: View {
    @Binding var value: CGPoint
    let title: String
    var size: CGFloat = 150

    var body: some View {
        let radius: CGFloat = size / 2
        let knob: CGFloat = size * 0.38
        let travel: CGFloat = radius - knob / 2
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(Color(.secondarySystemBackground))
                Circle().stroke(Color.secondary.opacity(0.5), lineWidth: 2)
                Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: 1, height: size)
                Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: size, height: 1)
                Circle().fill(Color.accentColor.opacity(0.85))
                    .frame(width: knob, height: knob)
                    .offset(x: value.x * travel, y: -value.y * travel)
            }
            .frame(width: size, height: size)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        var nx: CGFloat = (g.location.x - radius) / travel
                        var ny: CGFloat = -(g.location.y - radius) / travel
                        let m: CGFloat = (nx * nx + ny * ny).squareRoot()
                        if m > 1 {
                            nx /= m
                            ny /= m
                        }
                        value = CGPoint(x: nx, y: ny)
                    }
                    .onEnded { _ in value = .zero }
            )
            Text(title).font(.caption).foregroundColor(.secondary)
        }
    }
}
