//
//  CompassView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct CompassView: View {
    
    enum CompassHeadingMode:String, CaseIterable, Identifiable, Equatable, RawRepresentable, CustomStringConvertible{
        
        var id: String {self.rawValue}
        
        case trueHeading
        case magneticHeading
        
        static let defaultsKey = "CompassHeadingModeKey"
        
        var description: String{
            switch self {
            case .trueHeading:
                return NSLocalizedString("True", comment: "true heading")
            case .magneticHeading:
                return NSLocalizedString("Magnetic", comment: "magnetic heading")
            }
        }
    }
    
    @StateObject var magnetometer:Magnetometer = Magnetometer()
    
    @AppStorage(CompassHeadingMode.defaultsKey) var mode = CompassHeadingMode.trueHeading
    
    @AppStorage(AngularDisplayMode.defaultsKey) var displayMode:AngularDisplayMode = .navigational
    
    
    @State var minorFeedbackGenerator=UIImpactFeedbackGenerator(style: .light)
    @State var feedbackGenerator=UIImpactFeedbackGenerator(style: .medium)
    
    let clickInterval:Int=30
    let minorClickInterval:Int=10
    
    var body: some View {
        
        VStack{
            
            Picker(selection: $mode, content: {
                ForEach(CompassHeadingMode.allCases, content: {m in
                    Text(m.description).tag(m)
                })
            }, label: {
                Text("Compass Mode")
            })
                .pickerStyle(SegmentedPickerStyle())
                .fixedSize()
                .padding([.top], 15)
            Spacer()
            
            CompassHeadingView(heading: magnetometer.heading, attitude: magnetometer.attitude, mode: mode)
            
            Group{
                HeadingLabel(heading: Measurement<UnitAngle>.init(value: magnetometer.heading.trueHeading, unit: .degrees), description: NSLocalizedString("True Heading", comment: "heading title"), headingUncertainty: Measurement<UnitAngle>(value: magnetometer.heading.accuracy, unit: .degrees), isVariation: false, displayMode: displayMode)
                
                HeadingLabel(heading: Measurement<UnitAngle>.init(value: magnetometer.heading.magneticHeading, unit: .degrees), description: NSLocalizedString("Magnetic Heading", comment: "heading title"), headingUncertainty: Measurement<UnitAngle>(value: magnetometer.heading.accuracy, unit: .degrees), isVariation: false, displayMode: displayMode)
                
                HeadingLabel(heading: Measurement<UnitAngle>.init(value: magnetometer.heading.variation, unit: .degrees), description: NSLocalizedString("Variation", comment: "heading title"), headingUncertainty: nil, isVariation: true, displayMode: displayMode)
            }
            .contextMenu(ContextMenu(menuItems: {
                ForEach(AngularDisplayMode.allCases, id: \.id, content: {mode in
                     Button(action: {
                        self.displayMode=mode
                    }, label: {
                        Text(mode.description)
                    })
                })

            }))
            
            
            
            
            Spacer()
        }
        .onAppear(perform: {
            magnetometer.isRunning=true
        })
        .onDisappear(perform: {
            magnetometer.isRunning=false
        })
        .onReceive(magnetometer.$heading, perform: {heading in
            let intHeading:Int
            switch mode {
            case .trueHeading:
                intHeading=Int(heading.trueHeading)
            case .magneticHeading:
                intHeading=Int(heading.magneticHeading)
            }
            
            switch intHeading{
            case _ where intHeading.isMultiple(of: minorClickInterval):
                minorFeedbackGenerator.impactOccurred()
            case _ where intHeading.isMultiple(of: clickInterval):
                feedbackGenerator.impactOccurred()
            default:
                break
            }
        
            
        })
        
       
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}
