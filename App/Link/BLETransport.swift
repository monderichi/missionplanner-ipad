// BLE serial bridge transport (no Mission Planner equivalent: desktop MP uses Bluetooth SPP via a
// virtual COM port, which iPadOS doesn't offer). Supports the two common BLE UART layouts:
//   - Nordic UART Service (NUS): service 6E400001, RX/write 6E400002, TX/notify 6E400003
//   - HM-10 / CC254x: service FFE0, one characteristic FFE1 for both notify and write
// Only needs NSBluetoothAlwaysUsageDescription; no restricted entitlement.

import CoreBluetooth
import Foundation

enum BLEUUIDs {
    static let nusService = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    static let nusRX = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") // we write
    static let nusTX = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") // we get notified
    static let hm10Service = CBUUID(string: "FFE0")
    static let hm10Char = CBUUID(string: "FFE1")
    static let services = [nusService, hm10Service]
}

struct BLEDevice: Identifiable, Equatable {
    let id: UUID
    var name: String
    var rssi: Int
}

/// Scans for BLE UART bridges so the user can pick one in the connect sheet.
final class BLEScanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published private(set) var devices: [BLEDevice] = []
    @Published private(set) var status = "Bluetooth starting…"
    private var central: CBCentralManager?
    private var wantScan = false

    func start() {
        wantScan = true
        if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        } else {
            beginScanIfPossible()
        }
    }

    func stop() {
        wantScan = false
        central?.stopScan()
    }

    private func beginScanIfPossible() {
        guard wantScan, let central, central.state == .poweredOn else { return }
        devices.removeAll()
        status = "Scanning…"
        central.scanForPeripherals(withServices: BLEUUIDs.services,
                                   options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: beginScanIfPossible()
        case .unauthorized: status = "Bluetooth permission denied (Settings › Privacy › Bluetooth)"
        case .poweredOff: status = "Bluetooth is off"
        case .unsupported: status = "Bluetooth LE not supported"
        default: status = "Bluetooth unavailable"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = peripheral.name
            ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? "Unnamed device"
        if let i = devices.firstIndex(where: { $0.id == peripheral.identifier }) {
            devices[i].rssi = RSSI.intValue
            devices[i].name = name
        } else {
            devices.append(BLEDevice(id: peripheral.identifier, name: name, rssi: RSSI.intValue))
        }
    }
}

final class BLETransport: NSObject, MAVTransport, CBCentralManagerDelegate, CBPeripheralDelegate {
    var onReceive: ((Data) -> Void)?
    var onStateChange: ((LinkState) -> Void)?

    private let deviceID: UUID
    private let queue = DispatchQueue(label: "link.ble")
    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var writeChar: CBCharacteristic?
    private var closing = false

    init(deviceID: UUID) {
        self.deviceID = deviceID
    }

    func open() {
        closing = false
        onStateChange?(.connecting("Bluetooth"))
        central = CBCentralManager(delegate: self, queue: queue)
    }

    func close() {
        queue.async {
            self.closing = true
            if let p = self.peripheral { self.central?.cancelPeripheralConnection(p) }
            self.peripheral = nil
            self.writeChar = nil
            self.onStateChange?(.disconnected)
        }
    }

    func send(_ data: Data) {
        queue.async {
            guard let p = self.peripheral, let c = self.writeChar else { return }
            let noResponse = c.properties.contains(.writeWithoutResponse)
            let type: CBCharacteristicWriteType = noResponse ? .withoutResponse : .withResponse
            let mtu = max(20, p.maximumWriteValueLength(for: type))
            var offset = 0
            while offset < data.count {
                let end = min(offset + mtu, data.count)
                p.writeValue(data.subdata(in: offset..<end), for: c, type: type)
                offset = end
            }
        }
    }

    // MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            if central.state == .unauthorized { onStateChange?(.failed("Bluetooth permission denied")) }
            else if central.state == .poweredOff { onStateChange?(.failed("Bluetooth is off")) }
            return
        }
        if let p = central.retrievePeripherals(withIdentifiers: [deviceID]).first {
            connect(p)
        } else {
            // not cached yet: scan until we see it
            central.scanForPeripherals(withServices: BLEUUIDs.services, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard peripheral.identifier == deviceID else { return }
        central.stopScan()
        connect(peripheral)
    }

    private func connect(_ p: CBPeripheral) {
        peripheral = p
        p.delegate = self
        onStateChange?(.connecting(p.name ?? "Bluetooth device"))
        central?.connect(p, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(BLEUUIDs.services)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        onStateChange?(.failed(error?.localizedDescription ?? "Could not connect"))
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        writeChar = nil
        if closing { return }
        onStateChange?(.connecting("\(peripheral.name ?? "Bluetooth") (reconnecting)"))
        central.connect(peripheral, options: nil) // CoreBluetooth retries until it comes back
    }

    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services ?? [] {
            if s.uuid == BLEUUIDs.nusService {
                peripheral.discoverCharacteristics([BLEUUIDs.nusRX, BLEUUIDs.nusTX], for: s)
            } else if s.uuid == BLEUUIDs.hm10Service {
                peripheral.discoverCharacteristics([BLEUUIDs.hm10Char], for: s)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for c in service.characteristics ?? [] {
            switch c.uuid {
            case BLEUUIDs.nusTX:
                peripheral.setNotifyValue(true, for: c)
            case BLEUUIDs.nusRX:
                writeChar = c
            case BLEUUIDs.hm10Char:
                peripheral.setNotifyValue(true, for: c)
                writeChar = c
            default:
                break
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            onStateChange?(.failed(error.localizedDescription))
        } else if characteristic.isNotifying {
            onStateChange?(.open("BLE \(peripheral.name ?? "device")"))
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, !data.isEmpty {
            onReceive?(data)
        }
    }
}
