//
//  MagnetometerView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/11.
//

import SwiftUI

struct MagnetometerView: View {
    
    enum MagnetometerAxis:Int, Equatable, CustomStringConvertible, CaseIterable{
        case x
        case y
        case z
        
        var description: String{
            switch self {
            case .x:
                return NSLocalizedString("X", comment: "x axis")
            case .y:
                return NSLocalizedString("Y", comment: "y axis")
            case .z:
                return NSLocalizedString("Z", comment: "z axis")
            }
        }
        
        var color:Color{
            switch self {
            case .x:
                return .red
            case .y:
                return .green
            case .z:
                return .blue
            } 
        }
        
    }
    
    @StateObject var magnetometer:Magnetometer = Magnetometer()
    
    @State var axis = MagnetometerAxis.x
    
    var body: some View {
        
        VStack(spacing: 20.0){
            HStack{
                VStack(spacing: 15.0){
                    Text("Signal").font(.caption)
                    Picker(selection: $magnetometer.fieldOutput, label: EmptyView(), content: {
                        Text(Magnetometer.MagnetometerOutput.raw.description).tag(Magnetometer.MagnetometerOutput.raw)
                        Text(Magnetometer.MagnetometerOutput.calibrated.description).tag(Magnetometer.MagnetometerOutput.calibrated)
                    }).pickerStyle(SegmentedPickerStyle())//.fixedSize()
                }
                Spacer()
                VStack{
                    Text("Axis").font(.caption)
                    Picker(selection: $axis, content: {
                        ForEach(MagnetometerAxis.allCases, id: \.self, content: {a in
                            Text(a.description)
                                .foregroundColor(a.color)
                                .tag(a)
                        })
                    }, label: {EmptyView()})
                        .pickerStyle(.segmented)//.fixedSize()
                }
                
            }
            
            
            Group{
                switch axis {
                case .x:
                    switch magnetometer.fieldOutput{
                    case .raw:
                        Text(magnetometer.formatter.rawMagneticField.x)
                    case .geomagnetic:
                        Text(magnetometer.formatter.geomagneticField.x)
                    case .calibrated:
                        Text(magnetometer.formatter.magneticField.x)
                    }
                    
                case .y:
                    switch magnetometer.fieldOutput{
                    case .raw:
                        Text(magnetometer.formatter.rawMagneticField.y)
                    case .geomagnetic:
                        Text(magnetometer.formatter.geomagneticField.y)
                    case .calibrated:
                        Text(magnetometer.formatter.magneticField.y)
                    }
                case .z:
                    switch magnetometer.fieldOutput{
                    case .raw:
                        Text(magnetometer.formatter.rawMagneticField.z)
                    case .geomagnetic:
                        Text(magnetometer.formatter.geomagneticField.z)
                    case .calibrated:
                        Text(magnetometer.formatter.magneticField.z)
                    }
                }
            }.frame(maxWidth: .infinity)
                .padding(.vertical)
                .font(.largeTitle)
                .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(axis.color.opacity(0.2)))
            
            HStack{
                VStack{
                    Text("Unit").font(.caption)
                    Picker(selection: $magnetometer.formatter.outputFormat, label: Text(""), content: {
                        Text(MagnometerFormatter.OutputUnit.gauss.description).tag(MagnometerFormatter.OutputUnit.gauss)
                        Text(MagnometerFormatter.OutputUnit.microTesla.description).tag(MagnometerFormatter.OutputUnit.microTesla)
                    }).pickerStyle(SegmentedPickerStyle()).fixedSize()
                }
                
            }
            
            GroupBox{
                
                Button(action: {
                    switch magnetometer.fieldOutput{
                    case .calibrated:
                        magnetometer.zeroField = magnetometer.fieldModel.currentField
                    case .raw:
                        magnetometer.zeroField = magnetometer.rawMagneticField.field
                    case .geomagnetic:
                        magnetometer.zeroField = magnetometer.geomagneticField.field
                    }
                    
                    
                }, label: {
                    Text("Zero").font(.title2)
                }).frame(maxWidth: 200)
                
            }.contextMenu(ContextMenu(menuItems: {
                if #available(iOS 15.0, *) {
                    Button(role: .cancel, action: {
                        magnetometer.zeroField = .zeroField
                    }, label: {
                        Text("Reset")
                    })
                } else {
                    Button(action: {
                        magnetometer.zeroField = .zeroField
                    }, label: {
                        Text("Reset")
                    })
                }
               
            }))
            
            if magnetometer.zeroField != .zeroField{
                VStack(spacing: 0.0){
                    Text("Background")
                    Text(magnetometer.formatter.formattedField(field: magnetometer.zeroField).description)
                }.font(.caption2)
            }
            
            DefineAxesView()
            
            
            Spacer()
            
        }
        .padding(.all)
        
        .onAppear(perform: {
            magnetometer.isRunning=true
        })
        .onDisappear(perform: {
            magnetometer.isRunning=false
        })
        
    }
}

struct MagnetometerView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerView()
    }
}
