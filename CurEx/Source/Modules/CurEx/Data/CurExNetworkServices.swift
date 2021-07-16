//
//  CurExCurExNetworkServices.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExNetworkServices: CurExServicesDataSource {
    
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ()) {
        ///simulates a network response
        let content = CurExResponseModel.Response(text: "Network response")
        let modelResponse = CurExResponseModel(status: "SUCCESS", content: content, error: nil)
        if modelResponse.status == "SUCCESS" {
            if let text = modelResponse.content?.text {
                let model = CurExModel(CurExModel.Content(text))
                successful(model)
            } else {
                let error = NSError(domain: "ru.destplay.TechDemo", code: 999, userInfo: ["reason": "empty"])
                failure(error)
            }
        } else {
            guard let responseError = modelResponse.error else { return }
            let error = NSError(domain: "ru.destplay.TechDemo", code: responseError.code, userInfo: ["reason": responseError.reason])
            failure(error)
        }
    }
    
}
