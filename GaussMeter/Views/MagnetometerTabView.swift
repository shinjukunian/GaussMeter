//
//  TabView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/11/10.
//

import SwiftUI

struct MagnetometerTabView: View {
    
    enum Tabs:String{
        case magnetometer
        case compass
    }
    
    @StateObject var magnetometer=MagnetometerCommunicator()
    @SceneStorage("selectedTab") var selectedTab:Tabs = .magnetometer
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            GaussMeterView(communicator: magnetometer)
                .tabItem({
                Label(title: {Text("Magnetometer")}, icon: {Image(systemName: "gauge")})
                })
                .tag(Tabs.magnetometer)
            
            CompassView()
                .tabItem({
                Label(title: {Text("Compass")}, icon: {Image(systemName: "location.north.line")})
                })
                .tag(Tabs.compass)
            
           
        }
        
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MagnetometerTabView()
    }
}
