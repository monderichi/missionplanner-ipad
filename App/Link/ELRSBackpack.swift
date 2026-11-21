// Reads the ExpressLRS TX Backpack's MAVLink settings from its web server
// (GET http://10.0.0.1/mavlink, served by WebUpdateGetMavLink in ExpressLRS/Backpack devWIFI.cpp):
//   {"enabled":true,"counters":{"packets_down":735,"packets_up":220,"drops_down":100,"overflows_down":0},
//    "ports":{"listen":14555,"send":14551},"ip":{"gcs":"10.0.0.100"},"protocol":"UDP"}
// The app uses ports.listen as the remote port and ports.send as the iPad's local port, so a
// backpack configured to something other than 14555/14550 just works.

import Foundation

struct ELRSBackpackInfo: Decodable, Equatable {
    struct Ports: Decodable, Equatable {
        let listen: UInt16
        let send: UInt16
    }

    struct IP: Decodable, Equatable {
        let gcs: String?
    }

    struct Counters: Decodable, Equatable {
        let packets_down: Int?
        let packets_up: Int?
        let drops_down: Int?
        let overflows_down: Int?
    }

    let enabled: Bool?
    let ports: Ports
    let ip: IP?
    let counters: Counters?
    let `protocol`: String?

    var summary: String {
        var s = "Backpack listens on \(ports.listen), sends to iPad port \(ports.send)"
        if let gcs = ip?.gcs, !gcs.isEmpty, gcs != "0.0.0.0" { s += ", last GCS \(gcs)" }
        if enabled == false { s += ". MAVLink is DISABLED on the backpack" }
        return s
    }
}

enum ELRSBackpack {
    static func fetch(host: String, completion: @escaping (ELRSBackpackInfo?) -> Void) {
        guard let url = URL(string: "http://\(host)/mavlink") else { return completion(nil) }
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 3
        config.timeoutIntervalForResource = 4
        config.allowsCellularAccess = false // the backpack is only on Wi-Fi
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        session.dataTask(with: url) { data, response, _ in
            defer { session.finishTasksAndInvalidate() }
            guard let data, (response as? HTTPURLResponse)?.statusCode == 200,
                  let info = try? JSONDecoder().decode(ELRSBackpackInfo.self, from: data) else {
                return completion(nil)
            }
            completion(info)
        }.resume()
    }
}
