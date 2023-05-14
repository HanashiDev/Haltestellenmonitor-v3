//
//  GaussKrueger.swift
//  Haltestellenmonitor1-DD
//
//  Created by Peter Lohse on 14.05.23.
//

import Foundation
import CoreLocation

public struct GKCoordinate {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public func wgs2gk(wgs: CLLocationCoordinate2D) -> GKCoordinate? {
    guard let pot = wgs2pot(wgs: wgs) else { return nil }
    return pot2gk(pot: pot)
}

func pot2gk(pot: GKCoordinate) -> GKCoordinate? {
    let lp = pot.x
    let bp = pot.y

    if bp < 46 || bp > 56 || lp < 5 || lp > 16 {
        print("Werte außerhalb des für Deutschland definierten Gauss-Krüger-Systems\n 5° E < LP < 16° E, 46° N < BP < 55° N")
        return nil
    }

    // Potsdam Datum
    // Große Halbachse a und Abplattung f
    let a = 6377397.155
    let f = 3.342773154e-3
    let pi = Double.pi

    // Polkrümmungshalbmesser c
    let c = a/(1-f)

    // Quadrat der zweiten numerischen Exzentrizität
    let ex2 = (2*f-f*f)/((1-f)*(1-f))
    let ex4 = ex2*ex2
    let ex6 = ex4*ex2
    let ex8 = ex4*ex4

    // Koeffizienten zur Berechnung der Meridianbogenlänge
    let e0 = c*(pi/180)*(1 - 3*ex2/4 + 45*ex4/64  - 175*ex6/256  + 11025*ex8/16384)
    let e2 =            c*(  -3*ex2/8 + 15*ex4/32  - 525*ex6/1024 +  2205*ex8/4096)
    let e4 =                          c*(15*ex4/256 - 105*ex6/1024 +  2205*ex8/16384)
    let e6 =                                    c*( -35*ex6/3072 +   315*ex8/12288)

    // Breite in Radianten
    let br = bp * pi/180

    let tan1 = tan(br)
    let tan2 = tan1*tan1
    let tan4 = tan2*tan2

    let cos1 = cos(br)
    let cos2 = cos1*cos1
    let cos4 = cos2*cos2
    let cos3 = cos2*cos1
    let cos5 = cos4*cos1

    let etasq = ex2*cos2

    // Querkrümmungshalbmesser nd
    let nd = c/sqrt(1 + etasq)

    // Meridianbogenlänge g aus gegebener geographischer Breite bp
    let g = e0*bp + e2*sin(2*br) + e4*sin(4*br) + e6*sin(6*br)

    // Längendifferenz dl zum Bezugsmeridian lh
    let kz = Double(4) // Double(Int((+lp + 1.5) / 3))
    let lh = kz*3
    let dl = (lp - lh)*pi/180
    let dl2 = dl*dl
    let dl4 = dl2*dl2
    let dl3 = dl2*dl
    let dl5 = dl4*dl

    // Hochwert hw und Rechtswert rw als Funktion von geographischer Breite und Länge
    var hw =  (g + nd*cos2*tan1*dl2/2 + nd*cos4*tan1*(5-tan2+9*etasq)*dl4/24)
    var rw =      (nd*cos1*dl         + nd*cos3*(1-tan2+etasq)*dl3/6 + nd*cos5*(5-18*tan2+tan4)*dl5/120 + kz*1e6 + 500000)

    var nk = hw - Double(Int(hw))
    if nk < 0.5 {
        hw = Double(Int(hw))
    } else {
        hw = Double(Int(hw)) + 1
    }

    nk = rw - Double(Int(rw))
    if nk < 0.5 {
        rw = Double(Int(rw))
    } else {
        rw = Double(Int(rw + 1))
    }

    return GKCoordinate(x: rw, y: hw)
}

func wgs2pot(wgs: CLLocationCoordinate2D) -> GKCoordinate? {
    let lw = wgs.longitude
    let bw = wgs.latitude

    // Quellsystem WGS 84 Datum
    // Große Halbachse a und Abplattung fq
    let a = 6378137.000
    let fq = 3.35281066e-3

    // Zielsystem Potsdam Datum
    // Abplattung f
    let f = fq - 1.003748e-5

    // Parameter für datum shift
    let dx = -587.0
    let dy = -16.0
    let dz = -393.0

    // Quadrat der ersten numerischen Exzentrizität in Quell- und Zielsystem
    let e2q = (2*fq-fq*fq)
    let e2 = (2*f-f*f)

    // Breite und Länge in Radianten
    let pi = Double.pi
    let b1 = bw * (pi/180)
    let l1 = lw * (pi/180)

    // Querkrümmungshalbmesser nd
    let nd = a/sqrt(1 - e2q*sin(b1)*sin(b1))

    // Kartesische Koordinaten des Quellsystems WGS84
    let xw = nd*cos(b1)*cos(l1)
    let yw = nd*cos(b1)*sin(l1)
    let zw = (1 - e2q)*nd*sin(b1)

    // Kartesische Koordinaten des Zielsystems (datum shift) Potsdam
    let x = xw + dx
    let y = yw + dy
    let z = zw + dz

    // Berechnung von Breite und Länge im Zielsystem
    let rb = sqrt(x*x + y*y)
    let b2 = (180/pi) * atan((z/rb)/(1-e2))

    var l2 = 0.0
    if x > 0 {
        l2 = (180/pi) * atan(y/x)
    }
    if x < 0 && y > 0 {
        l2 = (180/pi) * atan(y/x) + 180
    }
    if x < 0 && y < 0 {
        l2 = (180/pi) * atan(y/x) - 180
    }

    if l2 < 5 || l2 > 16 || b2 < 46 || b2 > 56 {
        return nil
    }

    return GKCoordinate(x: l2, y: b2)
}
