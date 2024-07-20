//
//  IntentHandler.swift
//  MonitorIntents
//
//  Created by Peter Lohse on 19.04.23.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    func provideLineFilterOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<LineFilter>?, Error?) -> Void) {
        
        let lineItems: [LineFilter] = [
            LineFilter(identifier: "1", display: "1"),
            LineFilter(identifier: "2", display: "2"),
            LineFilter(identifier: "3", display: "3"),
            LineFilter(identifier: "4", display: "4"),
            LineFilter(identifier: "6", display: "6"),
            LineFilter(identifier: "7", display: "7"),
            LineFilter(identifier: "8", display: "8"),
            LineFilter(identifier: "9", display: "9"),
            LineFilter(identifier: "10", display: "10"),
            LineFilter(identifier: "11", display: "11"),
            LineFilter(identifier: "12", display: "12"),
            LineFilter(identifier: "13", display: "13"),
            LineFilter(identifier: "20", display: "20"),
            LineFilter(identifier: "61", display: "61"),
            LineFilter(identifier: "62", display: "62"),
            LineFilter(identifier: "63", display: "63"),
            LineFilter(identifier: "64", display: "64"),
            LineFilter(identifier: "65", display: "65"),
            LineFilter(identifier: "66", display: "66"),
            LineFilter(identifier: "68", display: "68"),
            LineFilter(identifier: "70", display: "70"),
            LineFilter(identifier: "72", display: "72"),
            LineFilter(identifier: "73", display: "73"),
            LineFilter(identifier: "74", display: "74"),
            LineFilter(identifier: "76", display: "76"),
            LineFilter(identifier: "77", display: "77"),
            LineFilter(identifier: "78", display: "78"),
            LineFilter(identifier: "79", display: "79"),
            LineFilter(identifier: "80", display: "80"),
            LineFilter(identifier: "81", display: "81"),
            LineFilter(identifier: "83", display: "83"),
            LineFilter(identifier: "84", display: "84"),
            LineFilter(identifier: "85", display: "85"),
            LineFilter(identifier: "86", display: "86"),
            LineFilter(identifier: "87", display: "87"),
            LineFilter(identifier: "88", display: "88"),
            LineFilter(identifier: "89", display: "89"),
            LineFilter(identifier: "90", display: "90"),
            LineFilter(identifier: "91", display: "91"),
            LineFilter(identifier: "92", display: "92"),
            LineFilter(identifier: "93", display: "93")
        ]
        
        let collection = INObjectCollection(items: lineItems)
        
        completion(collection, nil)
    }
    
    func provideStopTypeOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<StopType>?, Error?) -> Void) {
        
        var stopItems: [StopType] = []
        
        stops.forEach { stop in
            stopItems.append(StopType(identifier: String(stop.stopID), display: stop.getFullName()))
        }
        
        let collection = INObjectCollection(items: stopItems)
        
        completion(collection, nil)
    }
}
