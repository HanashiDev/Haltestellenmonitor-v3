//
//  DepartureRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

struct DepartureRequest: Hashable, Codable {
    var outputFormat = "rapidJSON"
    var mode = "direct"
    var useRealTime = 1

    
    var useProxFootSearch = 0
    var limit = 50
    var IsShowTrainsExplicit = 1
    var coordOutputFormat = "WGS84[dd.ddddd]"
    var locationServerActive = 1
    var useAllStops = 1

    var type_dm = "any"
    
    var name_dm: String
    var itdDate: String

}

func createDepartureRequest(stopId: String, itdDate: String, itdTime:String) -> String {
    return "mode=direct&outputFormat=rapidJSON&type_dm=stop&useProxFootSearch=0&useRealtime=1&limit=50&isShowTrainsExplicit=1&locationServerActive=1&useAllStops=1&name_dm=\(stopId)&itdDate=\(itdDate)&itdTime=\(itdTime)"
    
}
