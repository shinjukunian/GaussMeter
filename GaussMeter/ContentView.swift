//
//  ContentView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/17.
//

import SwiftUI

struct ContentView: View {
    
    @State var isRunning=false
    @State var shouldReset=false
    
    var body: some View {
        
        NavigationView{
                MagnetometerView(isRunning: $isRunning, shouldReset: $shouldReset)
                .padding(.vertical)
                .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(Text("Magnetometer"))
                .toolbar(content: {
                    ToolbarItem(placement: .bottomBar, content: {
                        Button(action: {
                            print("zero")
                        }, label: {
                            Text("Auto Zero")
                            
                        })
                    })
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button(action: {
                            shouldReset=true
                        }, label: {
                            Image(systemName: "arrow.counterclockwise")
                        }).disabled(self.isRunning == false)
                    })
                    
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button(action: {
                            
                            isRunning.toggle()
                            
                        }, label: {
                            if isRunning == true{
                                Text("Stop")
                            }
                            else{
                                Text("Start")
                            }
                        })
                    })
                })
        }
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
