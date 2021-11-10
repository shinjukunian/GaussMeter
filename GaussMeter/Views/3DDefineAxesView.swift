//
//  3dDefineAxesView.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/19.
//

import SwiftUI
import SceneKit
import Combine


class SceneHolder:ObservableObject{
    
    lazy var scene:SCNScene = {
        let url=Bundle.main.url(forResource: "iPhoneModel", withExtension: "scn")!
        let scene = try! SCNScene(url: url, options: [.checkConsistency:true])
        return scene
    }()
    
    var attitude:EulerAngles = .default{
        didSet{
            scene.rootNode.simdEulerAngles=attitude.simdAngles
        }
    }
    
}


struct ThreeDDefineAxesView: View {
    
    @StateObject var sceneHolder = SceneHolder()

    @Binding var attitude:EulerAngles
    
    var body: some View {
        
        SceneView(scene: sceneHolder.scene, pointOfView: nil, options: [ .autoenablesDefaultLighting], preferredFramesPerSecond: 30, antialiasingMode: .multisampling2X, delegate: nil, technique: nil)
            .aspectRatio(1, contentMode: .fit).frame(width: 50, height: 50, alignment: .trailing)
            .onReceive(Just(attitude), perform: {a in
                sceneHolder.attitude=a
            })
    }
}

struct ThreeDDefineAxesView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDDefineAxesView(attitude: Binding.constant(.default))
    }
}
