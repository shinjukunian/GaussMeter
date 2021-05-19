//
//  MagnetometerView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/18.
//

import SwiftUI
import Combine

struct MagnetometerView: View {
    
    @StateObject var magnetometer:Magnetometer = Magnetometer()
    @State var output = Magnetometer.MagnetometerOutput.raw
    
    @EnvironmentObject var communicator:MagnetometerCommunicator
    
    @State var shouldPresentShareSheet:Bool=false
    
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Picker(selection: $magnetometer.formatter.outputFormat, label: Text(""), content: {
                    Text(MagnometerFormatter.OutputUnit.gauss.description).tag(MagnometerFormatter.OutputUnit.gauss)
                    Text(MagnometerFormatter.OutputUnit.microTesla.description).tag(MagnometerFormatter.OutputUnit.microTesla)
                }).pickerStyle(SegmentedPickerStyle()).fixedSize()
                HeadingView(heading: $magnetometer.heading).fixedSize()
            }
            
            HStack{
                ValueDisplayView().environmentObject(magnetometer).fixedSize()
//                ThreeDDefineAxesView(attitude: $magnetometer.attitude)
                DefineAxesView()
            }
            
            Picker(selection: $output, label: Text(""), content: {
                Text(Magnetometer.MagnetometerOutput.raw.description).tag(Magnetometer.MagnetometerOutput.raw)
                Text(Magnetometer.MagnetometerOutput.calibrated.description).tag(Magnetometer.MagnetometerOutput.calibrated)
                Text(Magnetometer.MagnetometerOutput.geomagnetic.description).tag(Magnetometer.MagnetometerOutput.geomagnetic)
            }).pickerStyle(SegmentedPickerStyle()).fixedSize()
            
            
            self.fieldView
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding([.top, .leading, .trailing])
            Spacer()
        }
        .onAppear{
        }
        .onReceive(communicator.$shouldReset, perform: { v in
            if v == true{
                magnetometer.reset()
                communicator.shouldReset=false
            }
        })
        .onReceive(communicator.$isRunning, perform: { v in
            magnetometer.isRunning=v
        })
        .onReceive(communicator.$share, perform: { v in
            shouldPresentShareSheet=v
        })
        .sheet(isPresented: $shouldPresentShareSheet, onDismiss: {
            communicator.share=false
        }, content: {
            ActivityViewController(model: currentModel)
        })
        
        
    }
    
    var currentModel:FieldViewModel{
        switch output {
        case .calibrated:
            return magnetometer.calibratedFieldModel
        case .raw:
            return magnetometer.rawFieldModel
        case .geomagnetic:
            return magnetometer.geomagneticFieldModel
        }
    }
    
    
    var fieldView:some View{
        FieldView()
            .environment(\.outputUnit, magnetometer.formatter.outputFormat)
            .environmentObject(currentModel)
        
    }
    
    
}

struct MagnetometerView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerView().environmentObject(MagnetometerCommunicator())
    }
}

