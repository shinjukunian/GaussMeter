//
//  HeadingLabel.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

enum AngularDisplayMode:String, RawRepresentable, CaseIterable, CustomStringConvertible, Identifiable{
    
    static let defaultsKey = "AngularDisplayModeKey"
    
    var id:String {return rawValue}
    
    case decimal
    case minutes
    case wholeDegrees
    case navigational
    
    var description: String{
        switch self {
        case .decimal:
            return NSLocalizedString("Decimal Degrees", comment: "Angular display mode")
        case .minutes:
            return NSLocalizedString("Degrees + Minutes", comment: "Angular display mode")
        case .wholeDegrees:
            return NSLocalizedString("Degrees", comment: "Angular display mode")
        case .navigational:
            return NSLocalizedString("Navigation", comment: "Angular display mode")
        }
    }
    
    func formattedMeasurement(measurement:Measurement<UnitAngle>, formatter:MeasurementFormatter, isVariation:Bool = false)->String{
        
        switch self {
        case .decimal:
            formatter.unitOptions=[.providedUnit]
            formatter.unitStyle = .short
            return "\(formatter.string(from: measurement))"
            
        case .minutes:
            formatter.unitOptions=[.providedUnit]
            formatter.unitStyle = .short
            let degrees=measurement.converted(to: .degrees).value
            let integerDegrees=trunc(degrees)
            let integerMeasurement=Measurement<UnitAngle>(value: integerDegrees, unit: .degrees)
            let remainder=measurement-integerMeasurement
            let minutes=remainder.converted(to: .arcMinutes)
            
            return "\(formatter.string(from: integerMeasurement))  \(formatter.string(from: minutes))"
        case .wholeDegrees:
            formatter.unitOptions=[.providedUnit]
            formatter.unitStyle = .short
            formatter.numberFormatter.numberStyle = .none
            formatter.numberFormatter.maximumFractionDigits = 0
            let degrees=measurement.converted(to: .degrees)
            return formatter.string(from: degrees)
        case .navigational:
            var deg=measurement.converted(to: .degrees)
            let interval=22.5
            let label:String
            
            if isVariation{
                switch deg.value{
                case _ where deg.value < 0:
                    label=NSLocalizedString("W", comment: "west")
                default:
                    label=NSLocalizedString("E", comment: "east")
                }
                deg = Measurement.init(value: abs(deg.value), unit: .degrees)
            }
            else{
                switch deg.value{
                case (interval)..<(interval*3): // 22.5 ..< 67.5
                    label=NSLocalizedString("NE", comment: "north east")
                case (interval*3)..<(interval*5): // 67.5 ..< 112.5
                    label=NSLocalizedString("E", comment: "east")
                case (interval*5)..<(interval*7): // 112.5 ..< 157.5
                    label=NSLocalizedString("SE", comment: "southeast")
                case (interval*7)..<(interval*9): // 157.5 ..< 202.5
                    label=NSLocalizedString("S", comment: "southeast")
                case (interval*9)..<(interval*11): // 202.5 ..< 247.5
                    label=NSLocalizedString("SW", comment: "southwest")
                case (interval*11)..<(interval*13): // 247.5 ..< 292.5
                    label=NSLocalizedString("W", comment: "west")
                case (interval*13)..<(interval*15): // 292.5 ..< 337.5
                    label=NSLocalizedString("NW", comment: "northwest")
                default:// - 337.5 ..< 22.5
                    label=NSLocalizedString("N", comment: "north")
                }
            }
            
           
            
            formatter.unitOptions=[.providedUnit]
            formatter.unitStyle = .short
            formatter.numberFormatter.numberStyle = .none
            formatter.numberFormatter.maximumFractionDigits = 0
            return "\(formatter.string(from: deg)) \(label)"
        }
        
        
        
    }
    
}

struct HeadingLabel: View {
    
    let heading:Measurement<UnitAngle>
    let description:String
    let headingUncertainty:Measurement<UnitAngle>?
    
    let isVariation:Bool
    
    let displayMode:AngularDisplayMode
    
    var formatter=MeasurementFormatter()
    
    var headingLabel: some View{
        let head="\(description): \(displayMode.formattedMeasurement(measurement: heading, formatter: formatter, isVariation: isVariation))"
        if let headingUncertainty = headingUncertainty, displayMode != .navigational {
            return Text("\(head) ± \(displayMode.formattedMeasurement(measurement: headingUncertainty, formatter: formatter))")
                .foregroundColor(headingUncertainty.value < 0 ? Color.red : Color.primary)
        }
        else{
            return Text(head)
        }
    }
    
    var body: some View {
            headingLabel
    }
    
    
}


struct HeadingLabel_Previews: PreviewProvider {
    static var previews: some View {
        HeadingLabel(heading: .init(value: -112.445, unit: .degrees), description: "Heading", headingUncertainty: .init(value: 0.1, unit: .degrees), isVariation: true, displayMode: .navigational)
    }
}
