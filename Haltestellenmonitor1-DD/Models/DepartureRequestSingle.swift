//
//  DepartureRequestSingle.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.02.25.
//

struct DepartureRequestSingle: Hashable, Codable {
    var outputFormat = "rapidJSON"
    var mode = "direct"
    
    var stopId: String
    var time: String
    var date: String
    var line: String // line id
    var tripCode: String
    var tStOTType = "next"
    var useRealTime = "1"
}

func createDepartureRequestSingle(stopId: String, line:String, tripCode:Int, itdDate: String, itdTime:String, tStOTType:String = "NEXT") -> String {
    return "mode=direct&outputFormat=rapidJSON&useRealtime=1&limit=50&stopID=\(stopId)&tStOTType=\(tStOTType)&itdDate=\(itdDate)&itdTime=\(itdTime)&tripCode=\(tripCode)&line=\(line)"
}
