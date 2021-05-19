//
//  FieldViewModel+Coding.swift
//  GaussMeter
//
//  Created by Morten Bertz on 2021/05/19.
//

import Foundation
import CodableCSV
import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct FieldTabulatoryData: Equatable, Codable{
    let time:[Double]
    let x:[Double]
    let y:[Double]
    let z:[Double]
    
    private enum CodingKeys: Int, CodingKey {
            case time = 0
            case x = 1
            case y = 2
            case z = 3
        }
}


extension FieldViewModel{
    var tabulatoryData:FieldTabulatoryData{
        FieldTabulatoryData(time: self.fieldData.map({$0.timeStamp}), x: self.fieldData.map({$0.x}), y: self.fieldData.map({$0.y}), z: self.fieldData.map({$0.z}))
    }
    
    var codedTabulatoryData:String?{
        let encoder = CSVEncoder{$0.headers=Field.CodingKeys.allCases.map({$0.rawValue})}
        do{
            let data = try encoder.encode(fieldData, into: String.self)
            return data
        }
        catch let error{
            print(error)
            return nil
        }
    }
}




struct ActivityViewController: UIViewControllerRepresentable {

    var applicationActivities: [UIActivity]? = nil
    
    private let model : FieldViewModel
    
    init(model:FieldViewModel) {
        self.model=model
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [context.coordinator], applicationActivities: applicationActivities)
        controller.modalPresentationStyle = .automatic
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

    func makeCoordinator() -> ActivityViewController.Coordinator {
        Coordinator(model: self.model)
    }

    class Coordinator : NSObject, UIActivityItemSource {

        private let model : FieldViewModel

        init(model: FieldViewModel) {
            self.model = model
            super.init()
        }
        
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
            return String()
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
            switch activityType {
            
            default:
                return model.codedTabulatoryData
            }
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
            return UTType.plainText.identifier
        }

        
    }
}
