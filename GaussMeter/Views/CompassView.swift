//
//  CompassView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI




struct CompassView: View {
    @StateObject var magnetometer:Magnetometer = Magnetometer()
    
    var body: some View {
        
        VStack{
            CompassHeadingView(heading: magnetometer.heading.trueHeading, attitude: magnetometer.attitude)
            HeadingLabel(heading: Measurement<UnitAngle>.init(value: magnetometer.heading.trueHeading, unit: .degrees), description: NSLocalizedString("Heading", comment: "heading title"), headingUncertainty: Measurement<UnitAngle>(value: magnetometer.heading.accuracy, unit: .degrees), displayMode: .minutes)
        }.onAppear(perform: {
            magnetometer.isRunning=true
        }).onDisappear(perform: {
            magnetometer.isRunning=false
        })
        
       
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView()
    }
}
