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
    @Binding var isRunning:Bool
    @Binding var shouldReset:Bool
    
    
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
                ValueDisplayView().environmentObject(magnetometer)
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
            isRunning=true
            magnetometer.isRunning=isRunning
        }
        .onReceive(Just(self.shouldReset), perform: { v in
            if v == true{
                magnetometer.reset()
            }
            shouldReset=false
        })
        
    }
    
    
    func togleRunning(){
        self.isRunning.toggle()
        magnetometer.isRunning.toggle()
    }
    
    var fieldView:some View{
        let f=FieldView().environment(\.outputUnit, magnetometer.formatter.outputFormat)
        switch output {
        case .calibrated:
            return f
                .environmentObject(magnetometer.calibratedFieldModel)
        case .raw:
            return f
                .environmentObject(magnetometer.rawFieldModel)
        case .geomagnetic:
            return f
                .environmentObject(magnetometer.geomagneticFieldModel)
        }
    }
    
    func toggleRunning(){
        self.isRunning.toggle()
        self.magnetometer.isRunning.toggle()
    }
}

struct MagnetometerView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerView(isRunning: Binding.constant(true), shouldReset: Binding.constant(false))
    }
}

