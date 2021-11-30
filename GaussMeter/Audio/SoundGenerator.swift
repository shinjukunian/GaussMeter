//
//  SoundGenerator.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/20.
//

import Foundation
import AVFoundation
import Combine

enum Modulator: Identifiable, Equatable, CaseIterable, Hashable, CustomStringConvertible{
    
    var id: String{
        switch self {
        case .none:
            return "none"
        case .absoluteLogAmplitude(let axis):
            return "absoluteLogAmplitude_\(axis.id)"
        case .absoluteTotalAmplitude:
            return "absoluteTotalAmplitude"
        case .absoluteTotalLogAmplitude:
            return "absoluteTotalLogAmplitude"
        }
    }
    
    
    
    static var allCases: [Modulator] = [.absoluteTotalAmplitude, .absoluteTotalLogAmplitude, .absoluteLogAmplitude(axis: .x) ,.absoluteLogAmplitude(axis: .y), .absoluteLogAmplitude(axis: .z)]
    
    struct ModulationValues{
        let frequency:Float
        let amplitude:Float
        
        static let maxField:Double = 1000
        static let minField:Double = 0
    }
    
    var description: String{
        switch self {
        case .absoluteTotalAmplitude:
            return NSLocalizedString("Amplitude", comment: "Sound Modulator")
        case .absoluteTotalLogAmplitude:
            return NSLocalizedString("Log Amplitude", comment: "Sound modulator")
        case .none:
            return NSLocalizedString("Raw", comment: "sound modulator")
        case .absoluteLogAmplitude(let axis):
            switch axis {
            case .x:
                return NSLocalizedString("Log Amplitude X", comment: "sound modulator")
            case .y:
                return NSLocalizedString("Log Amplitude Y", comment: "sound modulator")
            case .z:
                return NSLocalizedString("Log Amplitude Z", comment: "sound modulator")
            }
        }
    }
    
    
//    static func == (lhs: Modulator, rhs: Modulator) -> Bool {
//        switch lhs {
//        case .absoluteTotalAmplitude:
//            switch rhs {
//            case .absoluteTotalAmplitude:
//                return true
//            case .absoluteTotalLogAmplitude, .none, .absoluteLogAmplitude(_):
//                return false
//            }
//        case .absoluteTotalLogAmplitude:
//            switch rhs {
//            case .absoluteTotalLogAmplitude:
//                return true
//            case .absoluteTotalAmplitude, .none, .absoluteLogAmplitude(_):
//                return false
//            }
//        case .none:
//            switch rhs {
//            case .none:
//                return true
//            case .absoluteTotalAmplitude, .absoluteTotalLogAmplitude, .absoluteLogAmplitude(_):
//                return false
//            }
//        case .absoluteLogAmplitude(let axis_left):
//            switch rhs {
//            case .absoluteTotalAmplitude, .absoluteTotalLogAmplitude, .none:
//                return false
//            case .absoluteLogAmplitude(let axis_right):
//                return axis_right == axis_left
//            }
//        }
//    }
    
    enum Axis:Equatable, Identifiable, Hashable, CaseIterable, CustomStringConvertible{
        case x
        case y
        case z
        
        var id: String{
            switch self {
            case .x:
                return "x"
            case .y:
                return "y"
            case .z:
                return "z"
            }
        }
        
        static let localizedTitel = NSLocalizedString("Axis", comment: "Modulator title")
        
        var description: String{
            switch self {
            case .x:
                return NSLocalizedString("X", comment: "axis x")
            case .y:
                return NSLocalizedString("Y", comment: "axis y")
            case .z:
                return NSLocalizedString("Z", comment: "axis x")
            }
        }
    }
    
    case absoluteTotalAmplitude
    case absoluteTotalLogAmplitude
    case none
    case absoluteLogAmplitude(axis:Axis)
    
    func modulationValues(field:Field)->ModulationValues{
        switch self {
        case .none:
            return ModulationValues(frequency: 1, amplitude: 1)
        case .absoluteTotalAmplitude:
            let abs=field.absSum
            
            let relativeField=1-max(min(abs/ModulationValues.maxField,0.9),0.1)
            return ModulationValues(frequency: 100/Float(relativeField), amplitude: 1)
        case .absoluteTotalLogAmplitude:
            let abs=log(max(field.absSum,1.01))
            return ModulationValues(frequency: min(100*Float(abs),10_000), amplitude: 1)
        case .absoluteLogAmplitude(let axis):
            let v:Double
            switch axis {
            case .x:
                v=abs(field.x)
            case .y:
                v=abs(field.y)
            case .z:
                v=abs(field.z)
            }
            let abs=log(max(v,1.01))
            return ModulationValues(frequency: min(100*Float(abs),10_000), amplitude: 1)
        }
    }
    
}

class SoundGenerator:ObservableObject{
    
    @Published var isRunning:Bool=false{
        didSet{
            if isRunning == true{
                self.start()
            }
            else{
                self.stop()
            }
        }
    }
    
    let engine:AVAudioEngine
    
    let node:AudioNode
    
    @Published var modulator = Modulator.absoluteTotalLogAmplitude
    
    var cancelables:Set<AnyCancellable>=Set<AnyCancellable>()

    init(subject:AnyPublisher<Field,Never>){
        
        self.engine = AVAudioEngine()
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)
        let sampleRate = Float(outputFormat.sampleRate)
        let node=AudioNode(sampleRate: sampleRate)
        self.node=node
        
        
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [])
        } catch let error{
            print("Failed to set audio session category. \(error)")
        }
        
        #endif
        
        let mainMixer = engine.mainMixerNode
        
        engine.connect(mainMixer, to: output, format: outputFormat)
        mainMixer.outputVolume = 1
        
        
        
        
        let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                        sampleRate: outputFormat.sampleRate,
                                        channels: 1,
                                        interleaved: outputFormat.isInterleaved)
        
        engine.attach(node.audioNode)
        engine.connect(node.audioNode, to: mainMixer, format: inputFormat)
        self.subscribe(to: subject)
    }
    
    func subscribe(to subject:AnyPublisher<Field, Never>){
        self.cancelables.forEach({$0.cancel()})
        self.cancelables.removeAll()
        
        subject.sink(receiveValue: {v in
            let mod=self.modulator.modulationValues(field: v)
            self.node.apply(modulator: mod)
            
        }).store(in: &cancelables)
    }
    
    func start(){
        DispatchQueue.global(qos: .background).async {
            do {
                
                try self.engine.start()
                
            } catch {
                print("Could not start engine: \(error)")
            }
        }
    }
    
    func stop(){
        engine.stop()
    }
    
}
