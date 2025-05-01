//
//  DepartureRequestSingle.swift
//  Haltestellenmonitor1-DD
//
//  Created by Tom Braune on 23.02.25.
//

func createDepartureRequestSingle(stopId: String, line: String, tripCode: Int, date: String, time: String, tStOTType: String = "NEXT") -> String {
    return "mode=direct&outputFormat=rapidJSON&useRealtime=1&limit=50&stopID=\(stopId)&tStOTType=\(tStOTType)&date=\(date)&time=\(time)&tripCode=\(tripCode)&line=\(line)"
}
