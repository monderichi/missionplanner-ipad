// REA Parity Source: MissionPlanner ExtLibs/Controls/HUD.cs (doPaint): sky/ground split rotated by
// roll and shifted by pitch, pitch ladder every 5° (labels every 10°), roll scale with
// 10/20/30/45/60° ticks and a roll pointer, heading tape on top, speed left, altitude right,
// armed/mode text and failsafe banner.

import SwiftUI

struct HUDView: View {
    var roll: Double
    var pitch: Double
    var heading: Double
    var airspeed: Double
    var groundspeed: Double
    var altitude: Double
    var climbRate: Double
    var armed: Bool
    var mode: String
    var linkAlive: Bool
    /// Heartbeats arrive but ATTITUDE doesn't: the horizon would be frozen, so say so.
    var attitudeStale: Bool = false

    // computed (not stored) so they don't make the memberwise init private
    private var sky: Color { Color(red: 0.20, green: 0.45, blue: 0.85) }
    private var ground: Color { Color(red: 0.45, green: 0.30, blue: 0.13) }

    var body: some View {
        Canvas { ctx, size in
            let w = Double(size.width), h = Double(size.height)
            let cx: Double = w / 2, cy: Double = h / 2
            let pxPerDeg: Double = h / 45 // ±22.5° of pitch visible

            // horizon
            var horizon = ctx
            horizon.translateBy(x: cx, y: cy)
            horizon.rotate(by: .degrees(-roll))
            horizon.translateBy(x: 0, y: pitch * pxPerDeg)
            let big = max(w, h) * 4
            horizon.fill(Path(CGRect(x: -big, y: -big, width: 2 * big, height: big)), with: .color(sky))
            horizon.fill(Path(CGRect(x: -big, y: 0, width: 2 * big, height: big)), with: .color(ground))
            horizon.stroke(line(from: CGPoint(x: -big, y: 0), to: CGPoint(x: big, y: 0)), with: .color(.white), lineWidth: 2)

            // pitch ladder
            for p in stride(from: -90, through: 90, by: 5) where p != 0 {
                let y = -Double(p) * pxPerDeg
                let major = p % 10 == 0
                let half = major ? w * 0.12 : w * 0.06
                horizon.stroke(line(from: CGPoint(x: -half, y: y), to: CGPoint(x: half, y: y)),
                               with: .color(.white.opacity(0.9)), lineWidth: major ? 1.5 : 1)
                if major {
                    let label = Text("\(p)").font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                    horizon.draw(label, at: CGPoint(x: -half - 14, y: y))
                    horizon.draw(label, at: CGPoint(x: half + 14, y: y))
                }
            }

            // roll scale (fixed) and pointer (rotates)
            let r = Double(min(w, h)) * 0.38
            var scale = ctx
            scale.translateBy(x: cx, y: cy)
            let rollTicks: [Double] = [-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60]
            for a in rollTicks {
                let rad: Double = (a - 90) * Double.pi / 180
                let len: Double = (a.truncatingRemainder(dividingBy: 30) == 0) ? 12 : 7
                let p1 = CGPoint(x: cos(rad) * r, y: sin(rad) * r)
                let p2 = CGPoint(x: cos(rad) * (r - len), y: sin(rad) * (r - len))
                scale.stroke(line(from: p1, to: p2), with: .color(.white), lineWidth: 2)
            }
            var pointer = scale
            pointer.rotate(by: .degrees(-roll))
            var tri = Path()
            tri.move(to: CGPoint(x: 0, y: -r + 2))
            tri.addLine(to: CGPoint(x: -7, y: -r + 14))
            tri.addLine(to: CGPoint(x: 7, y: -r + 14))
            tri.closeSubpath()
            pointer.fill(tri, with: .color(.yellow))

            // aircraft symbol
            var plane = Path()
            plane.move(to: CGPoint(x: cx - w * 0.18, y: cy))
            plane.addLine(to: CGPoint(x: cx - w * 0.06, y: cy))
            plane.addLine(to: CGPoint(x: cx, y: cy + 10))
            plane.addLine(to: CGPoint(x: cx + w * 0.06, y: cy))
            plane.addLine(to: CGPoint(x: cx + w * 0.18, y: cy))
            ctx.stroke(plane, with: .color(.yellow), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

            // heading tape
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: 26)), with: .color(.black.opacity(0.35)))
            let pxPerHdg: Double = w / 90
            let names = [0: "N", 45: "NE", 90: "E", 135: "SE", 180: "S", 225: "SW", 270: "W", 315: "NW"]
            let start = Int((heading - 45).rounded(.down)), end = Int((heading + 45).rounded(.up))
            for d in start...end where d % 5 == 0 {
                let x = cx + (Double(d) - heading) * pxPerHdg
                let norm = ((d % 360) + 360) % 360
                let tall = norm % 15 == 0
                ctx.stroke(line(from: CGPoint(x: x, y: 26), to: CGPoint(x: x, y: tall ? 16 : 21)), with: .color(.white), lineWidth: 1)
                if norm % 15 == 0 {
                    let s = names[norm] ?? "\(norm)"
                    ctx.draw(Text(s).font(.system(size: 10, weight: .bold)).foregroundColor(.white), at: CGPoint(x: x, y: 8))
                }
            }
            ctx.draw(Text(String(format: "%03.0f", heading)).font(.system(size: 13, weight: .heavy).monospacedDigit())
                        .foregroundColor(.yellow), at: CGPoint(x: cx, y: 38))

            // speed (left) / altitude (right) boxes
            let boxW: Double = 78, boxH: Double = 44
            let leftBox = CGRect(x: 8, y: cy - boxH / 2, width: boxW, height: boxH)
            let rightBox = CGRect(x: w - boxW - 8, y: cy - boxH / 2, width: boxW, height: boxH)
            for box in [leftBox, rightBox] {
                ctx.fill(Path(roundedRect: box, cornerRadius: 6), with: .color(.black.opacity(0.55)))
            }
            ctx.draw(Text(String(format: "%.1f", groundspeed)).font(.system(size: 18, weight: .bold).monospacedDigit()).foregroundColor(.white),
                     at: CGPoint(x: leftBox.midX, y: leftBox.midY - 6))
            ctx.draw(Text("GS m/s  AS \(String(format: "%.1f", airspeed))").font(.system(size: 8)).foregroundColor(.white.opacity(0.8)),
                     at: CGPoint(x: leftBox.midX, y: leftBox.maxY - 8))
            ctx.draw(Text(String(format: "%.1f", altitude)).font(.system(size: 18, weight: .bold).monospacedDigit()).foregroundColor(.white),
                     at: CGPoint(x: rightBox.midX, y: rightBox.midY - 6))
            ctx.draw(Text("ALT m  VS \(String(format: "%+.1f", climbRate))").font(.system(size: 8)).foregroundColor(.white.opacity(0.8)),
                     at: CGPoint(x: rightBox.midX, y: rightBox.maxY - 8))

            // armed / mode
            ctx.draw(Text(armed ? "ARMED" : "DISARMED").font(.system(size: 15, weight: .heavy))
                        .foregroundColor(armed ? .red : .green), at: CGPoint(x: cx, y: h - 40))
            ctx.draw(Text(mode).font(.system(size: 14, weight: .bold)).foregroundColor(.white),
                     at: CGPoint(x: cx, y: h - 20))

            if linkAlive && attitudeStale {
                let banner = CGRect(x: w * 0.15, y: cy - 50 - 30, width: w * 0.7, height: 30)
                ctx.fill(Path(roundedRect: banner, cornerRadius: 6), with: .color(.orange.opacity(0.9)))
                ctx.draw(Text("NO ATTITUDE DATA · re-requesting").font(.system(size: 14, weight: .heavy)).foregroundColor(.black),
                         at: CGPoint(x: banner.midX, y: banner.midY))
            }

            if !linkAlive {
                let banner = CGRect(x: w * 0.2, y: cy - 50 - 30, width: w * 0.6, height: 30)
                ctx.fill(Path(roundedRect: banner, cornerRadius: 6), with: .color(.red.opacity(0.85)))
                ctx.draw(Text("NO HEARTBEAT").font(.system(size: 16, weight: .heavy)).foregroundColor(.white),
                         at: CGPoint(x: banner.midX, y: banner.midY))
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityLabel("Artificial horizon: roll \(Int(roll)), pitch \(Int(pitch)), heading \(Int(heading))")
    }

    private func line(from a: CGPoint, to b: CGPoint) -> Path {
        var p = Path()
        p.move(to: a)
        p.addLine(to: b)
        return p
    }
}
