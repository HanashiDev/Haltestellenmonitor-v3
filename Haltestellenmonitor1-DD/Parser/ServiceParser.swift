//
//  ServiceParser.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 19.07.24.
//

import Foundation

class ServiceParser: XMLParser {
    var services: [Service] = []
    
    var service: Service = Service(plannedBay: "", timetabledTime: "", estimatedTime: "", operatingDayRef: "", journeyRef: "", ptMode: "", publishedLineName: "", destination: "")
    var currentElement: String = ""
    var plannedBay = false
    var publishedLineName = false
    var destination = false
    
    override init(data: Data) {
        super.init(data: data)
        self.delegate = self
    }
}

extension ServiceParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        switch elementName {
        case "trias:StopEventResult":
            self.service = Service(plannedBay: "", timetabledTime: "", estimatedTime: "", operatingDayRef: "", journeyRef: "", ptMode: "", publishedLineName: "", destination: "")
        case "trias:PlannedBay":
            self.plannedBay = true
        case "trias:PublishedLineName":
            self.publishedLineName = true
        case "trias:DestinationText":
            self.destination = true
        default: break
        }
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch (self.currentElement) {
        case "trias:TimetabledTime":
            self.service.timetabledTime += string
        case "trias:EstimatedTime":
            self.service.estimatedTime += string
        case "trias:Text":
            if plannedBay {
                self.service.plannedBay += string
            } else if publishedLineName {
                self.service.publishedLineName += string
            } else if destination {
                self.service.destination += string
            }
        case "trias:OperatingDayRef":
            self.service.operatingDayRef += string
        case "trias:JourneyRef":
            self.service.journeyRef += string
        case "trias:PtMode":
            self.service.ptMode += string
        default: break
        }
    }
    
    // Called when closing tag (`</elementName>`) is found
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "trias:StopEventResult":
            self.services.append(self.service)
        case "trias:PlannedBay":
            self.plannedBay = false
        case "trias:PublishedLineName":
            self.publishedLineName = false
        case "trias:DestinationText":
            self.destination = false
        default: break
        }
        currentElement = ""
    }
}
