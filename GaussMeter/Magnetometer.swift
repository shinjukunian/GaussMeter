//
//  Magnetometer.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import Foundation
import SwiftUI
import Combine

class Magnetometer: ObservableObject {
    
    enum MagnetometerOutput:String, Equatable, Identifiable, CustomStringConvertible{
        case raw
        case calibrated
        case geomagnetic
        
        var id:String {return self.rawValue}
        
        var description: String{
            switch self {
            case .calibrated:
                return NSLocalizedString("Calibrated", comment: "")
            case .raw:
                return NSLocalizedString("Raw", comment: "")
            case .geomagnetic:
                return NSLocalizedString("Geomagnetic", comment: "")
            }
        }
    }
    
    let manager=MagnetometerManager()
    let compass=Compass()
    
    @Published var rawMagneticField: MagnometerFormatter.FormattedField = .empty
    @Published var magneticField:MagnometerFormatter.FormattedField = .empty
    @Published var geomagneticField:MagnometerFormatter.FormattedField = .empty
    
    @Published var rawFieldModel: FieldViewModel
    @Published var calibratedFieldModel: FieldViewModel
    @Published var geomagneticFieldModel: FieldViewModel
    @Published var heading:Double=0
    
    @Published var isRunning:Bool=false{
        didSet{
            guard isRunning != oldValue else{return}
            if isRunning{
                self.start()
            }
            else{
                self.stop()
            }
        }
    }
    
    var formatter:MagnometerFormatter
    
    var cancelables:Set<AnyCancellable>=Set<AnyCancellable>()
    
    init() {
        self.formatter=MagnometerFormatter(magnetometer: manager, compass: self.compass)
        self.rawFieldModel=FieldViewModel(subject: manager.rawMagneticField)
        self.calibratedFieldModel=FieldViewModel(subject: manager.magneticField)
        self.geomagneticFieldModel=FieldViewModel(subject: compass.geomagneticField)
        formatter.$magneticField
            .receive(on: DispatchQueue.main)
            .assign(to: &$magneticField)
        formatter.$rawMagneticField
            .receive(on: DispatchQueue.main)
            .assign(to: &$rawMagneticField)
        formatter.$geomagneticField
            .receive(on: DispatchQueue.main)
            .assign(to: &$geomagneticField)
        compass.heading
            .receive(on: DispatchQueue.main)
            .assign(to: &$heading)
    }
    
    
    deinit {
        stop()
    }
    
    func reset(){
        self.geomagneticFieldModel.reset()
        self.calibratedFieldModel.reset()
        self.rawFieldModel.reset()
    }
    
    fileprivate func stop(){
        self.manager.stopUpdates()
        self.compass.stopHeadingUpdates()
        
    }
    
    fileprivate func start(){
        self.manager.startUpdates()
        self.compass.startHeadingUpdates()
        
    }
}
