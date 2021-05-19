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
}

struct ContentView: View {
        
    @StateObject var communicator = MagnetometerCommunicator()
    
    var body: some View {
        
        NavigationView{
            MagnetometerView().environmentObject(communicator)
                .padding(.vertical)
                .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(Text("Magnetometer"))
                .toolbar(content: {
//                    ToolbarItem(placement: .bottomBar, content: {
//                        Button(action: {
//                            print("zero")
//                        }, label: {
//                            Text("Auto Zero")
//
//                        })
//                    })
//                    ToolbarItem(placement: .bottomBar, content: {
//                        Button(action: {
//                            print("zero")
//                        }, label: {
//                            Image(systemName: "waveform")
//
//                        })
//                    })
                    
                    ToolbarItem(placement: .bottomBar, content: {
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
                                Text("Stop")
                            }
                            else{
                                Text("Start")
                            }
                        })
                    })
                })
        }.onAppear{
            communicator.isRunning=true
        }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
