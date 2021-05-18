//
//  Environment.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation
import SwiftUI

struct PlotColorsKey: EnvironmentKey {
    static var defaultValue: [Color] = [Color.red, Color.green, Color.blue]
}

struct OutputUnitKey: EnvironmentKey {
    static var defaultValue: MagnometerFormatter.OutputUnit = .microTesla
}

extension EnvironmentValues {
    var plotColors: [Color] {
        get { self[PlotColorsKey.self] }
        set { self[PlotColorsKey.self] = newValue }
    }
    var outputUnit: MagnometerFormatter.OutputUnit{
        get{
            return self[OutputUnitKey.self]
        }
        set{
            self[OutputUnitKey.self] = newValue
        }
    }
}
