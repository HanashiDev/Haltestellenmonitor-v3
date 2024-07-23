//
//  StopEventResponseParser.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 23.07.24.
//

import Foundation

class StopEventResponseParser: XMLParser {
    var stopEvents: [StopEvent] = []
    
    var stopEvent = StopEvent(ThisCall: CallAtStop(StopPointRef: "", StopPointName: ""), OperatingDayRef: "", JourneyRef: "", LineRef: "", DirectionRef: "", Mode: "", ModeName: "", PublishedLineName: "", DestinationText: "")
    var callAtStop = CallAtStop(StopPointRef: "", StopPointName: "")
    var serviceCall = ServiceCall()
    var currentElement = ""
    var isService = false
    var isMode = false
    var textPart = ""
    var isPreviousCall = false
    var isThisCall = false
    var isOnwardCall = false
    var isCall = false
    var isServiceCall = false
    
    override init(data: Data) {
        super.init(data: data)
        self.delegate = self
    }
}

extension StopEventResponseParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
        case "trias:StopEventResult":
            self.stopEvent = StopEvent(ThisCall: CallAtStop(StopPointRef: "", StopPointName: ""), OperatingDayRef: "", JourneyRef: "", LineRef: "", DirectionRef: "", Mode: "", ModeName: "", PublishedLineName: "", DestinationText: "")
        case "trias:PreviousCall":
            self.isPreviousCall = true
            self.isCall = true
            self.callAtStop = CallAtStop(StopPointRef: "", StopPointName: "")
        case "trias:ThisCall":
            self.isThisCall = true
            self.isCall = true
            self.callAtStop = CallAtStop(StopPointRef: "", StopPointName: "")
        case "trias:OnwardCall":
            self.isOnwardCall = true
            self.isCall = true
            self.callAtStop = CallAtStop(StopPointRef: "", StopPointName: "")
        case "trias:ServiceArrival":
            if self.isCall {
                self.isServiceCall = true
                self.serviceCall = ServiceCall()
            }
        case "trias:ServiceDeparture":
            if self.isCall {
                self.isServiceCall = true
                self.serviceCall = ServiceCall()
            }
        case "trias:Service":
            self.isService = true
        case "trias:Mode":
            if self.isService {
                self.isMode = true
            }
        case "trias:Name":
            if self.isMode {
                self.textPart = "MODE_NAME"
            }
        case "trias:PublishedLineName":
            if self.isService {
                self.textPart = "PUBLISHED_LINE_NAME"
            }
        case "trias:DestinationText":
            if self.isService {
                self.textPart = "DESTINATION_TEXT"
            }
        case "trias:RouteDescription":
            if self.isService {
                self.textPart = "ROUTE_DESCRIPTION"
            }
        case "trias:OriginText":
            if self.isService {
                self.textPart = "ORIGIN_TEXT"
            }
        case "trias:StopPointName":
            if self.isCall {
                self.textPart = "STOP_POINT_NAME"
            }
        case "trias:NameSuffix":
            if self.isCall {
                self.textPart = "NAME_SUFFIX"
            }
        case "trias:PlannedBay":
            if self.isCall {
                self.textPart = "PLANNED_BAY"
            }
        case "trias:EstimatedBay":
            if self.isCall {
                self.textPart = "ESTIMATED_BAY"
            }
        default: break
        }
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch (self.currentElement) {
        case "trias:OperatingDayRef":
            if self.isService {
                self.stopEvent.OperatingDayRef += string
            }
        case "trias:VehicleRef":
            if self.isService {
                if self.stopEvent.VehicleRef == nil {
                    self.stopEvent.VehicleRef = string
                } else {
                    self.stopEvent.VehicleRef! += string
                }
            }
        case "trias:JourneyRef":
            if self.isService {
                self.stopEvent.JourneyRef += string
            }
        case "trias:LineRef":
            if self.isService {
                self.stopEvent.LineRef += string
            }
        case "trias:DirectionRef":
            if self.isService {
                self.stopEvent.DirectionRef += string
            }
        case "trias:PtMode":
            if self.isMode {
                self.stopEvent.Mode += string
            }
        case "trias:Text":
            switch (self.textPart) {
            case "MODE_NAME":
                self.stopEvent.ModeName += string
            case "PUBLISHED_LINE_NAME":
                self.stopEvent.PublishedLineName += string
            case "DESTINATION_TEXT":
                self.stopEvent.DestinationText += string
            case "STOP_POINT_NAME":
                self.callAtStop.StopPointName += string
            case "ROUTE_DESCRIPTION":
                if self.stopEvent.RouteDescription == nil {
                    self.stopEvent.RouteDescription = string
                } else {
                    self.stopEvent.RouteDescription! += string
                }
            case "ORIGIN_TEXT":
                if self.stopEvent.OriginText == nil {
                    self.stopEvent.OriginText = string
                } else {
                    self.stopEvent.OriginText! += string
                }
            case "NAME_SUFFIX":
                if self.callAtStop.NameSuffix == nil {
                    self.callAtStop.NameSuffix = string
                } else {
                    self.callAtStop.NameSuffix! += string
                }
            case "PLANNED_BAY":
                if self.callAtStop.PlannedBay == nil {
                    self.callAtStop.PlannedBay = string
                } else {
                    self.callAtStop.PlannedBay! += string
                }
            case "ESTIMATED_BAY":
                if self.callAtStop.EstimatedBay == nil {
                    self.callAtStop.EstimatedBay = string
                } else {
                    self.callAtStop.EstimatedBay! += string
                }
            default: break
            }
        case "trias:OperatorRef":
            if self.isService {
                if self.stopEvent.OperatorRef == nil {
                    self.stopEvent.OperatorRef = string
                } else {
                    self.stopEvent.OperatorRef! += string
                }
            }
        case "trias:OriginStopPointRef":
            if self.isService {
                if self.stopEvent.OriginStopPointRef == nil {
                    self.stopEvent.OriginStopPointRef = string
                } else {
                    self.stopEvent.OriginStopPointRef! += string
                }
            }
        case "trias:DestinationStopPointRef":
            if self.isService {
                if self.stopEvent.DestinationStopPointRef == nil {
                    self.stopEvent.DestinationStopPointRef = string
                } else {
                    self.stopEvent.DestinationStopPointRef! += string
                }
            }
        case "trias:Unplanned":
            if self.isService {
                if self.stopEvent.Unplanned == nil {
                    self.stopEvent.Unplanned = string
                } else {
                    self.stopEvent.Unplanned! += string
                }
            }
        case "trias:Cancelled":
            if self.isService {
                if self.stopEvent.Cancelled == nil {
                    self.stopEvent.Cancelled = string
                } else {
                    self.stopEvent.Cancelled! += string
                }
            }
        case "trias:StopPointRef":
            if self.isCall {
                self.callAtStop.StopPointRef += string
            }
        case "trias:StopSeqNumber":
            if self.isCall {
                if self.callAtStop.StopSeqNumber == nil {
                    self.callAtStop.StopSeqNumber = string
                } else {
                    self.callAtStop.StopSeqNumber! += string
                }
            }
        case "trias:DemandStop":
            if self.isCall {
                if self.callAtStop.DemandStop == nil {
                    self.callAtStop.DemandStop = string
                } else {
                    self.callAtStop.DemandStop! += string
                }
            }
        case "trias:UnplannedStop":
            if self.isCall {
                if self.callAtStop.UnplannedStop == nil {
                    self.callAtStop.UnplannedStop = string
                } else {
                    self.callAtStop.UnplannedStop! += string
                }
            }
        case "trias:NotServicedStop":
            if self.isCall {
                if self.callAtStop.NotServicedStop == nil {
                    self.callAtStop.NotServicedStop = string
                } else {
                    self.callAtStop.NotServicedStop! += string
                }
            }
        case "trias:NoBoardingAtStop":
            if self.isCall {
                if self.callAtStop.NoBoardingAtStop == nil {
                    self.callAtStop.NoBoardingAtStop = string
                } else {
                    self.callAtStop.NoBoardingAtStop! += string
                }
            }
        case "trias:NoAlightingAtStop":
            if self.isCall {
                if self.callAtStop.NoAlightingAtStop == nil {
                    self.callAtStop.NoAlightingAtStop = string
                } else {
                    self.callAtStop.NoAlightingAtStop! += string
                }
            }
        case "trias:TimetabledTime":
            if self.isServiceCall {
                if self.serviceCall.TimetabledTime == nil {
                    self.serviceCall.TimetabledTime = string
                } else {
                    self.serviceCall.TimetabledTime! += string
                }
            }
        case "trias:EstimatedTime":
            if self.isServiceCall {
                if self.serviceCall.EstimatedTime == nil {
                    self.serviceCall.EstimatedTime = string
                } else {
                    self.serviceCall.EstimatedTime! += string
                }
            }
        default: break
        }
    }
    
    // Called when closing tag (`</elementName>`) is found
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "trias:StopEventResult":
            self.stopEvents.append(self.stopEvent)
        case "trias:PreviousCall":
            self.isPreviousCall = false
            self.isCall = false
            if self.stopEvent.PreviousCalls == nil {
                self.stopEvent.PreviousCalls = []
            }
            self.stopEvent.PreviousCalls?.append(self.callAtStop)
        case "trias:ThisCall":
            self.isThisCall = false
            self.isCall = false
            self.stopEvent.ThisCall = self.callAtStop
        case "trias:OnwardCall":
            self.isOnwardCall = false
            self.isCall = false
            if self.stopEvent.OnwardCalls == nil {
                self.stopEvent.OnwardCalls = []
            }
            self.stopEvent.OnwardCalls?.append(self.callAtStop)
        case "trias:ServiceArrival":
            if self.isCall {
                self.isServiceCall = false
                self.callAtStop.ServiceArrival = self.serviceCall
            }
        case "trias:ServiceDeparture":
            if self.isCall {
                self.isServiceCall = false
                self.callAtStop.ServiceDeparture = self.serviceCall
            }
        case "trias:Service":
            self.isService = false
        case "trias:Mode":
            if self.isService {
                self.isMode = false
            }
        case "trias:Name":
            if self.isMode {
                self.textPart = ""
            }
        case "trias:PublishedLineName":
            if self.isService {
                self.textPart = ""
            }
        case "trias:RouteDescription":
            if self.isService {
                self.textPart = ""
            }
        case "trias:OriginText":
            if self.isService {
                self.textPart = ""
            }
        case "trias:DestinationText":
            if self.isService {
                self.textPart = ""
            }
        case "trias:StopPointName":
            if self.isCall {
                self.textPart = ""
            }
        case "trias:NameSuffix":
            if self.isCall {
                self.textPart = ""
            }
        default: break
        }
        currentElement = ""
    }
}
