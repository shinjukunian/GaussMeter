//
//  AudioNode.swift
//  SignalGenerator
//
//  Created by Morten Bertz on 2021/05/19.
//

import Foundation
import AVFoundation

let twoPi = 2 * Float.pi

enum WaveForm:String, Identifiable, CaseIterable, CustomStringConvertible{

    typealias WaveformFunction = ((Float)->Float)
    
    case sine
    case triangle
    case square
    
    var id: String {
        return self.rawValue
    }
    
    var description: String{
        switch self {
        case .sine:
            return NSLocalizedString("Sine", comment: "")
        case .square:
            return NSLocalizedString("Square", comment: "")
        case .triangle:
            return NSLocalizedString("Triangle", comment: "")
        }
    }
    
    
    var function:WaveformFunction{
        switch self {
        case .sine:
            return {f in sin(f)}
        case .square:
            return {phase in
                if phase <= Float.pi {
                    return 1.0
                } else {
                    return -1.0
                }
            }
        case .triangle:
            return {phase in
                var value = (2.0 * (phase * (1.0 / twoPi))) - 1.0
                if value < 0.0 {
                    value = -value
                }
                return 2.0 * (value - 0.5)
            }
        }
    }
}


class AudioNode:ObservableObject, Identifiable, Equatable, Hashable{
    
    var frequency:Float = 440
    
    
    var amplitude:Float = 0.5
    var currentPhase:Float=0
    var waveFormFunction = WaveForm.sine.function
    
    
    var audioNode:AVAudioNode! //unavoidable due to the initializer
    
    init(sampleRate:Float) {
        self.audioNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let phaseIncrement = (twoPi / sampleRate) * self.frequency
            
            for frame in 0..<Int(frameCount) {
                
                let value = self.waveFormFunction(self.currentPhase) * self.amplitude
                
                self.currentPhase += phaseIncrement
            
                self.currentPhase=self.clamp(phase: self.currentPhase)
            
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }
            return noErr
        }
        
    }
    
    func apply(modulator:SoundGenerator.Modulator.ModulationValues){
        self.frequency=modulator.frequency
        self.amplitude=modulator.amplitude
    }
    
    func clamp(phase:Float)->Float{
        var currentPhase=phase
        if currentPhase >= twoPi {
            currentPhase -= twoPi
        }
        if currentPhase < 0.0 {
            currentPhase += twoPi
        }
        return currentPhase
    }
    
    static func == (lhs: AudioNode, rhs: AudioNode) -> Bool {
        return lhs.frequency == rhs.frequency &&
            lhs.amplitude == rhs.amplitude &&
            lhs.audioNode == rhs.audioNode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.frequency)
        hasher.combine(self.audioNode)
    }
}
