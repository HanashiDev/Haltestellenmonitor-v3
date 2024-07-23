//
//  DepartureRequest.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

import Foundation
import AEXML

struct DepartureRequest: Hashable, Codable {
    var stopPointRef: String
    var time: String?
    var lineRef: String?
    var directionRef: String?
    var numberOfResults: Int = 50
    var stopEventType: String = "both"
    var includePreviousCalls = false
    var includeOnwardCalls = false
    var includeRealtimeData = true
    
    func getXML() -> Data? {
        let xml = AEXMLDocument()
        let attributes = ["version": "1.2", "xmlns": "http://www.vdv.de/trias", "xmlns:siri" : "http://www.siri.org.uk/siri", "xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation" : "http://www.vdv.de/trias"]
        let trias = xml.addChild(name: "Trias", attributes: attributes)
        
        let serviceRequest = trias.addChild(name: "ServiceRequest")
        
        let requestTimestamp = serviceRequest.addChild(name: "siri:RequestTimestamp")
        requestTimestamp.value = Date.now.ISO8601Format()
        
        let requestorRef = serviceRequest.addChild(name: "siri:RequestorRef")
        requestorRef.value = "OpenService"
        
        let requestPayload = serviceRequest.addChild(name: "RequestPayload")
        
        let stopEventRequest = requestPayload.addChild(name: "StopEventRequest")
        
        let location = stopEventRequest.addChild(name: "Location")
        
        let locationRef = location.addChild(name: "LocationRef")
        
        let stopPointRef = locationRef.addChild(name: "StopPointRef")
        stopPointRef.value = self.stopPointRef
        
        if self.time != nil {
            let depArrTime = location.addChild(name: "DepArrTime")
            depArrTime.value = self.time
        }
        
        let params = stopEventRequest.addChild(name: "Params")
        
        if self.lineRef != nil {
            
        }
        
        let numberOfResults = params.addChild(name: "NumberOfResults")
        numberOfResults.value = String(self.numberOfResults)
        
        let stopEventType = params.addChild(name: "StopEventType")
        stopEventType.value = self.stopEventType
        
        if (self.includePreviousCalls) {
            let includePreviousCalls = params.addChild(name: "IncludePreviousCalls")
            includePreviousCalls.value = "true"
        }
        
        if (self.includeOnwardCalls) {
            let includeOnwardCalls = params.addChild(name: "IncludeOnwardCalls")
            includeOnwardCalls.value = "true"
        }
        
        if (self.includeRealtimeData) {
            let includeRealtimeData = params.addChild(name: "IncludeRealtimeData")
            includeRealtimeData.value = "true"
        }
        
        return xml.xml.data(using: .utf8)
    }
}
