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
    
    @Published var fieldModel:FieldViewModel
    
    @Published var attitude:EulerAngles = .default
        
    @Published var heading:Compass.Heading = .dummy
    
    private var outPut:AnyPublisher<Field,Never>{
        switch fieldOutput {
        case .raw:
            return manager.rawMagneticField
        case .calibrated:
            return manager.magneticField
        case .geomagnetic:
            return compass.geomagneticField
        }
    }
    
    @Published var fieldOutput:MagnetometerOutput = .raw{
        didSet{
            fieldModel=FieldViewModel(subject: outPut)
            if let g=self.generator{
                g.subscribe(to: outPut)
            }
        }
    }

    var generator:SoundGenerator?
    
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
        self.fieldModel=FieldViewModel(subject: manager.rawMagneticField)
        
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
        
        manager.attitude
            .receive(on: DispatchQueue.main)
            .assign(to: &$attitude)
    }
    
    
    deinit {
        stop()
    }
    
    func reset(){
        self.fieldModel.reset()
       
    }
    
    fileprivate func stop(){
        self.manager.stopUpdates()
        self.compass.stopHeadingUpdates()
        
    }
    
    fileprivate func start(){
        self.manager.startUpdates()
        self.compass.startHeadingUpdates()
        
    }
    
    func playSound(modulator:Modulator){
        DispatchQueue.global(qos: .userInitiated).async {
            self.generator=SoundGenerator(subject: self.outPut)
            self.generator?.modulator=modulator
            self.generator?.start()
        }
    }
    
    func stopSound(){
        generator?.stop()
        generator=nil
    }
    
}
