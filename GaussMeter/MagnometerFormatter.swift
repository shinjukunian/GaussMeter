//
//  MagnometerFormatter.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/17.
//

import Foundation
import Combine

class MagnometerFormatter: ObservableObject{
    
    enum OutputUnit:String, Identifiable, Hashable, CustomStringConvertible{
        case gauss
        case microTesla
        case Tesla
        
        var id: String { self.rawValue }
        
        var measurementUnit:UnitMagneticField{
            switch self {
            case .Tesla:
                return .tesla
            case .gauss:
                return .gauss
            case .microTesla:
                return .microTeslas
            }
        }
        
        var description: String{
            switch self {
            case .Tesla:
                return "Tesla (T)"
            case .gauss:
                return "Gauss (G)"
            case .microTesla:
                return "micro Tesla (µT)"
            }
        }
        
        
    }
    
    struct FormattedField: CustomStringConvertible{
        var x:String
        let y:String
        let z:String
        
        let field:Field
        
        static let empty = FormattedField()
        
        init() {
            self.x=String(0)
            self.y=String(0)
            self.z=String(0)
            self.field=Field()
        }
        
        init(field:Field, formatter:MeasurementFormatter, format:OutputUnit, zeroField:Field? = nil) {
            if let zero=zeroField{
                let sub=field-zero
                self.x=formatter.string(from: sub.measurementX.converted(to: format.measurementUnit))
                self.y=formatter.string(from: sub.measurementY.converted(to: format.measurementUnit))
                self.z=formatter.string(from: sub.measurementZ.converted(to: format.measurementUnit))
                self.field=sub
            }
            else{
                self.x=formatter.string(from: field.measurementX.converted(to: format.measurementUnit))
                self.y=formatter.string(from: field.measurementY.converted(to: format.measurementUnit))
                self.z=formatter.string(from: field.measurementZ.converted(to: format.measurementUnit))
                self.field=field
            }
        }
        
        var description: String{
            return String(format: NSLocalizedString("X: %@ Y:%@ Z:%@", comment: "Formatted Field"), self.x, self.y, self.z)
        }
    }
    
    
    @Published var rawMagneticField:FormattedField = .empty
    @Published var magneticField:FormattedField = .empty
    @Published var geomagneticField:FormattedField = .empty
    
    @Published var outputFormat = OutputUnit.microTesla
    
    let measurementFormatter:MeasurementFormatter
    var cancelables:Set<AnyCancellable>=Set<AnyCancellable>()

    
    var zeroField:Field = .zeroField
    
    
    init(magnetometer:MagnetometerManager, compass:Compass) {
        self.measurementFormatter=MeasurementFormatter()
        self.measurementFormatter.unitOptions = [.providedUnit]
        self.measurementFormatter.unitStyle = .medium
        self.measurementFormatter.numberFormatter.numberStyle = .scientific
        self.measurementFormatter.numberFormatter.maximumFractionDigits=1
        self.measurementFormatter.numberFormatter.minimumFractionDigits=1
        
        
        magnetometer.magneticField.receive(on: DispatchQueue.global(qos: .background))
            .throttle(for: .seconds(0.2), scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: {_ in}, receiveValue: {f in
                self.magneticField=FormattedField(field: f, formatter: self.measurementFormatter, format: self.outputFormat, zeroField: self.zeroField)
            })
            .store(in: &cancelables)
        
        magnetometer.rawMagneticField.receive(on: DispatchQueue.global(qos: .background))
            .throttle(for: .seconds(0.2), scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: {_ in}, receiveValue: { [self]f in
                self.rawMagneticField=FormattedField(field: f, formatter: self.measurementFormatter, format: self.outputFormat, zeroField: zeroField)
            })
            .store(in: &cancelables)
        
        compass.geomagneticField.receive(on: DispatchQueue.global(qos: .background))
            .throttle(for: .seconds(0.2), scheduler: RunLoop.main, latest: true)
            .sink(receiveCompletion: {_ in}, receiveValue: {f in
                self.geomagneticField=FormattedField(field: f, formatter: self.measurementFormatter, format: self.outputFormat, zeroField: self.zeroField)
            })
            .store(in: &cancelables)
    }
    
    
    func formattedField(field:Field)->FormattedField{
        return FormattedField(field: field, formatter: self.measurementFormatter, format: self.outputFormat, zeroField: nil)
    }
    
}
