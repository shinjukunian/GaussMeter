//
//  SoundGenerator.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/20.
//

import Foundation
import AVFoundation
import Combine

class SoundGenerator:ObservableObject{
    
    enum Modulator:String, Identifiable, Equatable{
        
        struct ModulationValues{
            let frequency:Float
            let amplitude:Float
            
            static let maxField:Double = 1000
            static let minField:Double = 0
        }
        
        var id: String {return self.rawValue}
        
        case absoluteAmplitude
        case absoluteLogAmplitude
        case none
        
        func modulationValues(field:Field)->ModulationValues{
            switch self {
            case .none:
                return ModulationValues(frequency: 1, amplitude: 1)
            case .absoluteAmplitude:
                let abs=field.absSum
                
                let relativeField=1-max(min(abs/ModulationValues.maxField,0.9),0.1)
                return ModulationValues(frequency: 100/Float(relativeField), amplitude: 1)
            case .absoluteLogAmplitude:
                
                let abs=log(max(field.absSum,1.01))
                return ModulationValues(frequency: 100*Float(abs), amplitude: 1)
            }
        }
        
    }
    
    
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
    
    @Published var modulator = Modulator.absoluteLogAmplitude
    
    var cancelables:Set<AnyCancellable>=Set<AnyCancellable>()

    init(subject:AnyPublisher<Field,Never>){
        
        self.engine = AVAudioEngine()
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)
        let sampleRate = Float(outputFormat.sampleRate)
        let node=AudioNode(sampleRate: sampleRate)
        self.node=node
        
        
//        #if os(iOS)
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            // Set the audio session category, mode, and options.
//            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
//            try audioSession.setPreferredSampleRate(22050)
//            try audioSession.setActive(true, options: [])
//        } catch {
//            print("Failed to set audio session category.")
//        }
//        
//        #endif
        
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
