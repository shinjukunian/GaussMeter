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
    
    var description: String{
        switch self {
        case .decimal:
            return NSLocalizedString("Decimal Degrees", comment: "Angular display mode")
        case .minutes:
            return NSLocalizedString("Degrees + Minutes", comment: "Angular display mode")
        case .wholeDegrees:
            return NSLocalizedString("Degrees", comment: "Angular display mode")
        }
    }
    
    func formattedMeasurement(measurement:Measurement<UnitAngle>, formatter:MeasurementFormatter)->String{
        
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
        }
        
        
        
    }
    
}

struct HeadingLabel: View {
    
    let heading:Measurement<UnitAngle>
    let description:String
    let headingUncertainty:Measurement<UnitAngle>
    
    @AppStorage(AngularDisplayMode.defaultsKey) var displayMode:AngularDisplayMode = .minutes
    
    var formatter=MeasurementFormatter()
    
    var body: some View {
        Text("\(description): \(displayMode.formattedMeasurement(measurement: heading, formatter: formatter)) ± \(displayMode.formattedMeasurement(measurement: headingUncertainty, formatter: formatter))")
            .foregroundColor(headingUncertainty.value < 0 ? Color.red : Color.primary)
        
            .contextMenu(ContextMenu(menuItems: {
                ForEach(AngularDisplayMode.allCases, id: \.id, content: {mode in
                    return Button(action: {
                        self.displayMode=mode
                    }, label: {
                        Text(mode.description)
                    })
                })

            }))
    }
    
    
}


struct HeadingLabel_Previews: PreviewProvider {
    static var previews: some View {
        HeadingLabel(heading: .init(value: 90.445, unit: .degrees), description: "Heading", headingUncertainty: .init(value: 0.1, unit: .degrees), displayMode: .decimal)
    }
}
