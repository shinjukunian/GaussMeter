//
//  ContentView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/17.
//

import SwiftUI


class MagnetometerCommunicator:ObservableObject{
    
    @Published var isRunning:Bool=false
    @Published var shouldReset:Bool=false
    @Published var share:Bool=false
    @Published var playSound:Bool=false
    @Published var soundModulator:Modulator = .absoluteTotalLogAmplitude
}

struct GaussMeterChartView: View {
        
    @ObservedObject var communicator: MagnetometerCommunicator
    
    var body: some View {
        
        NavigationView{
            GaussMeterChartViewBody().environmentObject(communicator)
                .padding(.vertical)
                .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(Text("Magnetometer"))
                .toolbar(content: {

                    ToolbarItem(placement: .navigationBarLeading, content: {
                        Button(action: {
                            communicator.playSound.toggle()
                        }, label: {
                            if communicator.playSound{
                                Image(systemName: "speaker.slash")
                            }
                            else{
                                Image(systemName: "speaker")
                            }
                        }).contextMenu(ContextMenu(menuItems: {
                            if !communicator.playSound{
                                Button(action: {
                                    communicator.soundModulator = .absoluteTotalLogAmplitude
                                }, label: {
                                    Text("log sum")
                                    if communicator.soundModulator == .absoluteTotalLogAmplitude{
                                        Image(systemName: "checkmark")
                                    }
                                })
                                
                                Button(action: {
                                    communicator.soundModulator = .absoluteLogAmplitude(axis: .x)
                                }, label: {
                                    Text("log X")
                                    if communicator.soundModulator == .absoluteLogAmplitude(axis: .x){
                                        Image(systemName: "checkmark")
                                    }
                                })
                                
                                Button(action: {
                                    communicator.soundModulator = .absoluteLogAmplitude(axis: .y)
                                }, label: {
                                    Text("log Y")
                                    if communicator.soundModulator == .absoluteLogAmplitude(axis: .y){
                                        Image(systemName: "checkmark")
                                    }
                                })
                                
                                Button(action: {
                                    communicator.soundModulator = .absoluteLogAmplitude(axis: .z)
                                }, label: {
                                    Text("log Z")
                                    if communicator.soundModulator == .absoluteLogAmplitude(axis: .z){
                                        Image(systemName: "checkmark")
                                    }
                                })
                                
                                Button(action: {
                                    communicator.soundModulator = .absoluteTotalAmplitude
                                }, label: {
                                    Text("sum")
                                    if communicator.soundModulator == .absoluteTotalAmplitude {
                                        Image(systemName: "checkmark")
                                    }
                                })
                            }
                            
                            
                        }))
                    })
                   
//                    ToolbarItem(placement: .bottomBar, content:{
//                        Spacer()
//
//                    })
                    
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        Button(action: {
                            communicator.isRunning=false
                            communicator.share=true
                        }, label: {
                            Image(systemName: "square.and.arrow.up")

                        })
                    })
                    
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button(action: {
                            communicator.shouldReset=true
                        }, label: {
                            Image(systemName: "arrow.counterclockwise")
                        }).disabled(communicator.isRunning == false)
                    })
                    
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button(action: {
                            
                            communicator.isRunning.toggle()
                            
                        }, label: {
                            if communicator.isRunning == true{
                                Image(systemName: "stop")
                            }
                            else{
                                Image(systemName: "record.circle")
                            }
                        })
                    })
                })
        }.onAppear{
            communicator.isRunning=true
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
            communicator.isRunning=false
        })
    }
    
}
    

struct GaussMeterChartView_Previews: PreviewProvider {
    static var previews: some View {
        GaussMeterChartView(communicator: MagnetometerCommunicator())
    }
}
