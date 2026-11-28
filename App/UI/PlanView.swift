// REA Parity Source: MissionPlanner GCSViews/FlightPlanner.cs: map + waypoint grid, Read/Write WPs,
// Load/Save WP file, default alt + frame (Relative/Absolute/Terrain), fence and rally editing,
// and the Auto WP > Survey (Grid) tool (ExtLibs/Utilities/Grid.cs).

import MapKit
import MAVLinkKit
import SwiftUI
import UniformTypeIdentifiers

enum PlanTarget: String, CaseIterable, Identifiable {
    case mission = "Mission", fence = "Fence", rally = "Rally", survey = "Survey", circle = "Circle"
    var id: String { rawValue }

    var mapTarget: MapEditTarget {
        switch self {
        case .mission: return .mission
        case .fence: return .fence
        case .rally: return .rally
        case .survey: return .survey
        case .circle: return .circle
        }
    }

    var missionType: MissionType? {
        switch self {
        case .mission: return .mission
        case .fence: return .fence
        case .rally: return .rally
        case .survey, .circle: return nil
        }
    }
}

struct PlanView: View {
    @EnvironmentObject var vehicle: VehicleModel
    @EnvironmentObject var mission: MissionStore
    @AppStorage("map.source") private var sourceRaw = TileSource.appleHybrid.rawValue
    @State private var target = PlanTarget.mission
    @State private var addMode = true
    @State private var editing: EditRef?
    @State private var showLoad = false
    @State private var showImporter = false
    @State private var alert: String?
    @State private var confirmClear = false
    @State private var visible: (MKMapRect, Int)?
    @State private var circleCenter: GeoPoint?
    @State private var circleRadius = 100.0

    struct EditRef: Identifiable {
        let type: MissionType
        let index: Int
        var id: String { "\(type.rawValue)-\(index)" }
    }

    private var source: TileSource { TileSource(rawValue: sourceRaw) ?? .appleHybrid }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            if let b = mission.banner {
                Text(b)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.accentColor.opacity(0.12))
                    .onTapGesture { mission.banner = nil }
            }
            HStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    MapCanvas(vehicle: vehicle, mission: mission, tileSource: source,
                              editTarget: addMode ? target.mapTarget : .none,
                              previewCenter: target == .circle ? circleCenter : nil,
                              previewRadius: target == .circle ? circleRadius : 0,
                              onTap: { p in tap(p) },
                              onMove: { t, i, p in move(t, i, p) },
                              onSelect: { t, i in select(t, i) },
                              regionChanged: { rect, zoom in visible = (rect, zoom) })
                    MapToolsMenu(sourceRaw: $sourceRaw, visible: visible).padding(10)
                    if addMode {
                        Text(hint).font(.caption).padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, 16)
                    }
                }
                Divider()
                Group {
                    if target == .survey {
                        SurveyPanel()
                    } else if target == .circle {
                        CirclePanel(center: $circleCenter, radius: $circleRadius)
                    } else if let type = target.missionType {
                        PlanItemList(type: type, onEdit: { i in editing = EditRef(type: type, index: i) })
                    }
                }
                .frame(width: 360)
            }
        }
        .sheet(item: $editing) { ref in
            MissionItemEditor(type: ref.type, index: ref.index)
                .environmentObject(mission)
                .environmentObject(vehicle)
        }
        .sheet(isPresented: $showLoad) {
            ParamFilePicker(files: mission.savedFiles(), onPick: { url in
                showLoad = false
                load(url)
            }, onBrowse: {
                showLoad = false
                showImporter = true
            }, title: "Load mission", folderName: "missions", fileKind: ".waypoints")
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item]) { result in
            if case .success(let url) = result { load(url) }
        }
        .alert(alert ?? "", isPresented: Binding(get: { alert != nil }, set: { if !$0 { alert = nil } })) {
            Button("OK", role: .cancel) {}
        }
        .task {
            // Test automation: -MPReadMission YES reads the mission once the vehicle is attached.
            guard UserDefaults.standard.bool(forKey: "MPReadMission") else { return }
            for _ in 0..<30 {
                if mission.isAttached { mission.read(.mission); break }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
        .confirmationDialog("Clear \(target.rawValue.lowercased())?", isPresented: $confirmClear, titleVisibility: .visible) {
            Button("Clear", role: .destructive) {
                if let t = target.missionType {
                    mission.clear(t)
                } else if target == .circle {
                    circleCenter = nil
                } else {
                    mission.surveyPolygon = []
                }
            }
        } message: {
            Text("This only clears the plan on the iPad. Tap Write to change the vehicle.")
        }
    }

    private var hint: String {
        switch target {
        case .mission: return "Tap the map to add a waypoint · drag a marker to move it · tap a marker to edit"
        case .fence: return "Tap to add fence vertices (one inclusion polygon) · drag to move"
        case .rally: return "Tap to add a rally point · drag to move"
        case .survey: return "Tap to outline the survey area · drag corners to adjust · then Generate"
        case .circle: return "Tap the map to set the circle centre · then set radius and Generate"
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker("Edit", selection: $target) {
                ForEach(PlanTarget.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .frame(width: 400)
            Toggle(isOn: $addMode) { Label("Add on tap", systemImage: "hand.tap") }
                .toggleStyle(.button)
            Spacer()
            if let busy = mission.busy {
                if let p = mission.progress {
                    ProgressView(value: Double(p.done), total: Double(max(p.total, 1))).frame(width: 100)
                    Text("\(busy.label) \(p.done)/\(p.total)").font(.caption).monospacedDigit()
                } else {
                    ProgressView()
                    Text(busy.label).font(.caption)
                }
            }
            if let type = target.missionType {
                Button { mission.read(type) } label: { Label("Read", systemImage: "arrow.down.circle") }
                    .disabled(!mission.isAttached || mission.busy != nil)
                Button { mission.write(type) } label: { Label("Write", systemImage: "arrow.up.circle") }
                    .disabled(!mission.isAttached || mission.busy != nil)
            }
            if target == .mission {
                Menu {
                    Button { showLoad = true } label: { Label("Load .waypoints…", systemImage: "folder") }
                    Button {
                        do {
                            let url = try mission.save()
                            alert = "Saved to Files › Mission Planner › missions › \(url.lastPathComponent)"
                        } catch {
                            alert = "Save failed: \(error.localizedDescription)"
                        }
                    } label: { Label("Save .waypoints", systemImage: "square.and.arrow.down") }
                        .disabled(mission.mission.count < 2)
                } label: { Label("File", systemImage: "doc") }
            }
            Button(role: .destructive) { confirmClear = true } label: { Label("Clear", systemImage: "trash") }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func tap(_ p: GeoPoint) {
        if target == .survey {
            mission.surveyPolygon.append(p)
        } else if target == .circle {
            circleCenter = p
        } else if let t = target.missionType {
            mission.add(t, at: p)
        }
    }

    private func move(_ t: MapEditTarget, _ i: Int, _ p: GeoPoint) {
        switch t {
        case .survey:
            if mission.surveyPolygon.indices.contains(i) { mission.surveyPolygon[i] = p }
        case .mission: mission.move(.mission, index: i, to: p)
        case .fence: mission.move(.fence, index: i, to: p)
        case .rally: mission.move(.rally, index: i, to: p)
        case .none, .circle: break
        }
    }

    private func select(_ t: MapEditTarget, _ i: Int) {
        switch t {
        case .mission: editing = EditRef(type: .mission, index: i)
        case .fence: editing = EditRef(type: .fence, index: i)
        case .rally: editing = EditRef(type: .rally, index: i)
        default: break
        }
    }

    private func load(_ url: URL) {
        do {
            try mission.load(url)
            target = .mission
        } catch {
            alert = "Couldn't load \(url.lastPathComponent): \(error)"
        }
    }
}

/// Item list beside the map (Mission Planner's waypoint grid).
struct PlanItemList: View {
    @EnvironmentObject var mission: MissionStore
    @EnvironmentObject var vehicle: VehicleModel
    let type: MissionType
    let onEdit: (Int) -> Void

    var body: some View {
        let items = mission.items(type)
        List {
            if type != .fence {
                Section {
                    HStack {
                        Text("Default alt")
                        Spacer()
                        TextField("m", value: $mission.defaultAltitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 70)
                        Text("m")
                    }
                    Picker("Altitude frame", selection: $mission.defaultFrame) {
                        Text("Relative to home").tag(MAVFrame.globalRelativeAlt)
                        Text("Absolute (AMSL)").tag(MAVFrame.global)
                        Text("Above terrain").tag(MAVFrame.globalTerrainAlt)
                    }
                    if type == .mission {
                        HStack {
                            Button("+ Takeoff") { insertCommand(MissionCmd.takeoff, at: 1) }
                            Spacer()
                            Button("+ RTL") { insertCommand(MissionCmd.returnToLaunch, at: items.count) }
                            Spacer()
                            Button("+ Land") { insertCommand(MissionCmd.land, at: items.count) }
                        }
                        .buttonStyle(.bordered)
                        Text(summary(items)).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Section {
                if items.isEmpty || (type == .mission && items.count <= 1) {
                    Text("Nothing yet. Tap the map, or Read from the vehicle.").foregroundColor(.secondary)
                }
                ForEach(Array(items.enumerated()), id: \.offset) { i, it in
                    Button { onEdit(i) } label: { row(i, it) }
                        .buttonStyle(.plain)
                        .deleteDisabled(type == .mission && i == 0)
                        .moveDisabled(type == .mission && i == 0)
                }
                .onDelete { mission.delete(type, at: $0) }
                .onMove { mission.moveItems(type, from: $0, to: $1) }
            } header: {
                HStack {
                    Text(type.label)
                    Spacer()
                    EditButton()
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(_ i: Int, _ it: MissionItem) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(type == .mission && i == 0 ? "H" : "\(type == .mission ? i : i + 1)")
                .font(.system(.body, design: .monospaced)).fontWeight(.bold)
                .frame(width: 30, alignment: .leading)
                .foregroundColor(vehicle.currentWaypoint == i && type == .mission ? .green : .primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(type == .mission && i == 0 ? "Home" : MissionCommandCatalog.name(it.command, vehicleType: vehicle.vehicleType))
                if it.hasLocation {
                    Text(String(format: "%.6f, %.6f", it.latitude, it.longitude))
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer()
            if it.hasLocation || it.command == MissionCmd.takeoff {
                Text(String(format: "%.0f m", it.z)).font(.callout).monospacedDigit()
            }
        }
        .contentShape(Rectangle())
    }

    private func summary(_ items: [MissionItem]) -> String {
        let n = max(0, items.count - 1)
        let d = mission.missionDistance
        return "\(n) items · \(d >= 1000 ? String(format: "%.2f km", d / 1000) : String(format: "%.0f m", d)) path"
    }

    private func insertCommand(_ cmd: UInt16, at index: Int) {
        mission.ensureHome(fallback: vehicle.position)
        let alt: Float = cmd == MissionCmd.takeoff ? mission.defaultAltitude : 0
        mission.insert(.mission, MissionItem(frame: mission.defaultFrame, command: cmd, altitude: alt), at: index)
    }
}

/// Edits one mission/fence/rally item with Mission Planner's per-command parameter labels.
struct MissionItemEditor: View {
    @EnvironmentObject var mission: MissionStore
    @EnvironmentObject var vehicle: VehicleModel
    @Environment(\.dismiss) private var dismiss
    let type: MissionType
    let index: Int
    @State private var item = MissionItem()
    @State private var invalidPosition = false // BUG-007
    @State private var loaded = false

    private var commands: [MissionCommandInfo] { MissionCommandCatalog.commands(vehicleType: vehicle.vehicleType) }
    private var info: MissionCommandInfo? { commands.first { $0.id == item.command } }
    private var isHome: Bool { type == .mission && index == 0 }

    var body: some View {
        NavigationStack {
            Form {
                if type == .mission && !isHome {
                    Section("Command") {
                        Picker("Command", selection: $item.command) {
                            if info == nil {
                                Text(MissionCommandCatalog.name(item.command, vehicleType: vehicle.vehicleType)).tag(item.command)
                            }
                            ForEach(commands) { c in Text(c.title).tag(c.id) }
                        }
                        .pickerStyle(.navigationLink)
                    }
                }
                Section("Parameters") {
                    let labels = info?.p ?? defaultLabels
                    paramField(labels[safe: 0] ?? "", $item.param1)
                    paramField(labels[safe: 1] ?? "", $item.param2)
                    paramField(labels[safe: 2] ?? "", $item.param3)
                    paramField(labels[safe: 3] ?? "", $item.param4)
                }
                Section("Position") {
                    numberRow("Latitude", Binding(get: { item.latitude }, set: { item.latitude = $0 }), digits: 7)
                    numberRow("Longitude", Binding(get: { item.longitude }, set: { item.longitude = $0 }), digits: 7)
                    numberRow("Altitude (m)", Binding(get: { Double(item.z) }, set: { item.z = Float($0) }), digits: 1)
                    if !isHome {
                        Picker("Altitude frame", selection: $item.frame) {
                            Text("Relative to home").tag(MAVFrame.globalRelativeAlt)
                            Text("Absolute (AMSL)").tag(MAVFrame.global)
                            Text("Above terrain").tag(MAVFrame.globalTerrainAlt)
                            if ![MAVFrame.global, MAVFrame.globalRelativeAlt, MAVFrame.globalTerrainAlt].contains(item.frame) {
                                Text("Frame \(item.frame)").tag(item.frame)
                            }
                        }
                    }
                    if let p = vehicle.position {
                        Button("Use vehicle position") {
                            item.latitude = p.latitude
                            item.longitude = p.longitude
                        }
                    }
                }
                if type == .mission && !isHome && mission.isAttached {
                    Section {
                        Button("Fly to this waypoint now (set current)") { mission.setCurrent(index) }
                    } footer: {
                        Text("The vehicle continues the mission from here when in AUTO.")
                    }
                }
                if !isHome {
                    Section {
                        Button("Delete", role: .destructive) {
                            mission.delete(type, at: IndexSet(integer: index))
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isHome ? "Home" : "\(type.label) item \(type == .mission ? index : index + 1)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // BUG-007: typed latitude ≥ 214.75 trapped; 90…214 was silently stored and uploaded.
                        if MissionCmd.hasLocation(item.command),
                           !MissionItem.isValidCoordinate(latitude: item.latitude, longitude: item.longitude) {
                            invalidPosition = true
                            return
                        }
                        mission.update(type, index: index, item)
                        dismiss()
                    }
                    .alert("Invalid position", isPresented: $invalidPosition) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Latitude must be between -90 and 90, longitude between -180 and 180.")
                    }
                }
            }
            .onAppear {
                guard !loaded else { return }
                loaded = true
                if let it = mission.items(type)[safe: index] { item = it }
            }
        }
    }

    private var defaultLabels: [String] {
        switch item.command {
        case MissionCmd.fencePolygonInclusion, MissionCmd.fencePolygonExclusion: return ["Vertex count", "", "", ""]
        case MissionCmd.fenceCircleInclusion, MissionCmd.fenceCircleExclusion: return ["Radius (m)", "", "", ""]
        default: return ["Param 1", "Param 2", "Param 3", "Param 4"]
        }
    }

    @ViewBuilder
    private func paramField(_ label: String, _ value: Binding<Float>) -> some View {
        if !label.isEmpty {
            numberRow(label, Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = Float($0) }), digits: 2)
        }
    }

    private func numberRow(_ label: String, _ value: Binding<Double>, digits: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, value: value, format: .number.precision(.fractionLength(0...digits)))
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 200)
        }
    }
}

/// Survey (grid) generator panel.
struct SurveyPanel: View {
    @EnvironmentObject var mission: MissionStore
    @AppStorage("survey.spacing") private var spacing = 20.0
    @AppStorage("survey.angle") private var angle = 0.0
    @AppStorage("survey.alt") private var altitude = 50.0
    @AppStorage("survey.overshoot") private var overshoot = 0.0
    @AppStorage("survey.trigger") private var trigger = 0.0
    @State private var result: String?

    private var options: SurveyGrid.Options {
        var o = SurveyGrid.Options()
        o.spacing = spacing
        o.angle = angle
        o.altitude = Float(altitude)
        o.overshoot = overshoot
        return o
    }

    var body: some View {
        let preview = SurveyGrid.generate(polygon: mission.surveyPolygon, options: options)
        Form {
            Section("Area") {
                LabeledContent("Corners", value: "\(mission.surveyPolygon.count)")
                LabeledContent("Area", value: String(format: "%.2f ha", Geo.area(mission.surveyPolygon) / 10_000))
                if !mission.surveyPolygon.isEmpty {
                    Button("Remove last corner") { mission.surveyPolygon.removeLast() }
                }
            }
            Section("Grid") {
                row("Line spacing (m)", $spacing)
                row("Angle (°)", $angle)
                Slider(value: $angle, in: 0...180, step: 5)
                row("Altitude (m)", $altitude)
                row("Overshoot (m)", $overshoot)
                row("Camera trigger distance (m, 0 = off)", $trigger)
            }
            Section {
                LabeledContent("Waypoints", value: "\(preview.count)")
                LabeledContent("Lines", value: "\(preview.count / 2)")
                Button {
                    let n = mission.addSurvey(options: options, cameraTriggerDistance: Float(trigger))
                    result = n > 0 ? "Added \(n) survey waypoints to the mission" : "Outline at least 3 corners first"
                } label: {
                    Label("Generate into mission", systemImage: "square.grid.3x3")
                }
                .disabled(mission.surveyPolygon.count < 3)
                if let r = result { Text(r).font(.caption).foregroundColor(.secondary) }
            } footer: {
                Text("Waypoints are appended after the current mission items. Review them under Mission, then Write.")
            }
        }
    }

    private func row(_ label: String, _ value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
        }
    }
}

/// Circle / orbit generator panel (Mission Planner Auto WP > Circle).
struct CirclePanel: View {
    @EnvironmentObject var mission: MissionStore
    @Binding var center: GeoPoint?
    @Binding var radius: Double
    @AppStorage("circle.points") private var points = 12
    @AppStorage("circle.alt") private var altitude = 50.0
    @AppStorage("circle.clockwise") private var clockwise = true
    @AppStorage("circle.turns") private var turns = 1
    @AppStorage("circle.loiter") private var asLoiter = false
    @State private var result: String?

    var body: some View {
        Form {
            Section("Centre") {
                if let c = center {
                    Text(String(format: "%.6f, %.6f", c.latitude, c.longitude)).font(.callout).monospacedDigit()
                } else {
                    Text("Tap the map to place the centre").foregroundColor(.secondary)
                }
            }
            Section("Circle") {
                row("Radius (m)", $radius)
                row("Altitude (m)", $altitude)
                Picker("Direction", selection: $clockwise) {
                    Text("Clockwise").tag(true)
                    Text("Counter-clockwise").tag(false)
                }
                .pickerStyle(.segmented)
                Stepper("Turns: \(turns)", value: $turns, in: 1...5)
                Toggle("Insert as a single LOITER_TURNS item", isOn: $asLoiter)
                if !asLoiter {
                    Stepper("Points per turn: \(points)", value: $points, in: 4...36)
                }
            }
            Section {
                LabeledContent("Items to add", value: asLoiter ? "1" : "\(points * turns)")
                Button {
                    guard let c = center else { return }
                    let n = mission.addCircle(center: c, radius: radius, points: points, altitude: Float(altitude),
                                              clockwise: clockwise, turns: turns, asLoiterTurns: asLoiter)
                    result = n > 0 ? "Added \(n) item\(n == 1 ? "" : "s") to the mission" : "Radius must be above 0"
                } label: {
                    Label("Generate into mission", systemImage: "circle.dashed")
                }
                .disabled(center == nil || radius <= 0)
                if let r = result { Text(r).font(.caption).foregroundColor(.secondary) }
            } footer: {
                Text("A LOITER_TURNS item is how ArduPilot flies a true orbit. Waypoints are appended after the current mission items; review them under Mission, then Write.")
            }
        }
    }

    private func row(_ label: String, _ value: Binding<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
        }
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}
