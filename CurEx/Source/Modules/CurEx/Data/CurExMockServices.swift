//
//  CurExCurExMockServices.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExMockServices: CurExServicesDataSource {
    
    var mockFile: CurExJsonMockType
    
    init(_ mockFile: CurExJsonMockType) {
        self.mockFile = mockFile
    }
    
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ()) {
        ///simulates a network response
        
        guard let data = MockManager.fileJson(fileName: self.mockFile.getNameFile()) else {
            let error = NSError(domain: "ru.destplay.TechDemo", code: 991, userInfo: ["reason": "Данные не найдены"])
            failure(error)
            return
        }
        
        MockManager.parseJson(data: data, success: { (modelResponse: CurExResponseModel) in
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
        }, failure: failure)
    }
    
}

class MockManager {
    static func fileJson(fileName: String) -> Data? {
        do {
            guard let file = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                return nil
            }
            let data = try Data(contentsOf: file)
            
            print(String(data: data, encoding: .utf8) ?? "")
            
            return data
        } catch {
            
            return nil
        }
    }
    
    static func parseJson<T: Decodable>(data: Data, success: ((T) -> ()), failure: ((NSError) -> ())) {
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            success(model)
        } catch {
            failure(error as NSError)
        }
    }
}
