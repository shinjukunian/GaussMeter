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
    
    @EnvironmentObject var communicator:MagnetometerCommunicator
    
    @State var shouldPresentShareSheet:Bool=false
    
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Picker(selection: $magnetometer.formatter.outputFormat, label: Text(""), content: {
                    Text(MagnometerFormatter.OutputUnit.gauss.description).tag(MagnometerFormatter.OutputUnit.gauss)
                    Text(MagnometerFormatter.OutputUnit.microTesla.description).tag(MagnometerFormatter.OutputUnit.microTesla)
                }).pickerStyle(SegmentedPickerStyle()).fixedSize()
                
                HeadingView(heading: magnetometer.heading.trueHeading).fixedSize()
            }
            
            HStack{
                ValueDisplayView().environmentObject(magnetometer).fixedSize()
//                ThreeDDefineAxesView(attitude: $magnetometer.attitude)
//                DefineAxesView().fixedSize()
            }
            
            
            Picker(selection: $magnetometer.fieldOutput, label: Text(""), content: {
                Text(Magnetometer.MagnetometerOutput.raw.description).tag(Magnetometer.MagnetometerOutput.raw)
                Text(Magnetometer.MagnetometerOutput.calibrated.description).tag(Magnetometer.MagnetometerOutput.calibrated)
                Text(Magnetometer.MagnetometerOutput.geomagnetic.description).tag(Magnetometer.MagnetometerOutput.geomagnetic)
            }).pickerStyle(SegmentedPickerStyle()).fixedSize()
            
            Text("Accuracy: \(magnetometer.fieldModel.currentField.accuracy.description)").font(.caption2)
            
            self.fieldView
                .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxHeight: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding([.top, .leading, .trailing])
            Spacer()
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
        .onReceive(communicator.$playSound, perform: { play in
            if play == true{
                magnetometer.playSound(modulator: communicator.soundModulator)
            }
            else{
                magnetometer.stopSound()
            }
        })
        .sheet(isPresented: $shouldPresentShareSheet, onDismiss: {
            communicator.share=false
        }, content: {
            ActivityViewController(model: magnetometer.fieldModel)
        })
        
        
    }
    
    
    
    
    var fieldView:some View{
        FieldView()
            .environment(\.outputUnit, magnetometer.formatter.outputFormat)
            .environmentObject(magnetometer.fieldModel)
        
    }
    
    
}

struct MagnetometerView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerView().environmentObject(MagnetometerCommunicator())
    }
}

