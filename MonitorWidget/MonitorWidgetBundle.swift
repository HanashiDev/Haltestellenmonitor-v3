//
//  MonitorWidgetBundle.swift
//  MonitorWidget
//
//  Created by Peter Lohse on 19.04.23.
//

import WidgetKit
import SwiftUI

@main
struct MonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        MonitorWidget()
        MonitorWidgetLiveActivity()
    }
}
