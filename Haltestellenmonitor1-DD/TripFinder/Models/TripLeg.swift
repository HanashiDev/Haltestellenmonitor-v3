//
//  TripLeg.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 25.07.25.
//

struct TripLeg: Hashable, Codable {
    let duration: Int
    let origin: Place
    let destination: Place
    let transportation: Transportation
    // let hints: [Hint]?
    let stopSequence: [StopEvent]
    let infos: [Info]?

    let coords: [[Double]] // [(x,y)]
    struct PathDescription: Hashable, Codable {
        let name: String
        let coord: [Double] // x, y
    }
    let pathDescription: PathDescription?

    struct Interchange: Hashable, Codable {
        let desc: String
        let coords: [[Double]] // [(x,y)]
    }
    let interchange: Interchange?

    struct FootPathInfo: Hashable, Codable {
        let position: String
        let duration: Int

        struct FootPathElement: Hashable, Codable {
            let type: String
            let level: Int
        }
        let footPahtElem: [FootPathElement]
    }
    let footPathInfo: FootPathInfo?
    let footPathInfoRedundant: Bool?

}
