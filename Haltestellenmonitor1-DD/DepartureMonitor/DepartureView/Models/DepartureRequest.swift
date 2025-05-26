//
//  DepartureRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

func createDepartureRequest(stopId: String, itdDate: String, itdTime: String) -> String {
    return "mode=direct&outputFormat=rapidJSON&type_dm=stop&useProxFootSearch=0&useRealtime=1&limit=50&lsShowTrainsExplicit=1&locationServerActive=1&useAllStops=1&name_dm=\(stopId)&itdDate=\(itdDate)&itdTime=\(itdTime)"

}
