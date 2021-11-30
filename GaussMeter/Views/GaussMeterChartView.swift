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
        
    @StateObject var communicator=MagnetometerCommunicator()
    
    var body: some View {
        
        NavigationView{
            GaussMeterChartViewBody().environmentObject(communicator)
                .padding(.vertical)
                .navigationBarTitleDisplayMode(.inline)
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
                            
                            Picker(selection: $communicator.soundModulator, content: {
                                ForEach(Modulator.allCases, content: {mod in
                                    Text(mod.description).tag(mod)
                                })
                            }, label: {
                                Text("Method")
                            })

                        }))
                    })
                   
                    
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
