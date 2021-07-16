//
//  CurExCurExModel.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import Foundation

protocol CurExViewViewer: AnyObject {
    func response(_ model: CurExViewModel)
    func response(_ error: NSError)
}

protocol CurExPresenterDataSource: AnyObject {
    func fetch(objectFor view: CurExViewViewer)
}

protocol CurExPresenterViewer: AnyObject {
    func response(_ model: CurExModel)
    func response(_ error: NSError)
}

protocol CurExInteractorDataSource: AnyObject {
    func fetch(objectFor presenter: CurExPresenterViewer)
}

protocol CurExInteractorViewer: AnyObject {
    func response(_ model: CurExModel)
    func response(_ error: NSError)
}

protocol CurExRepositoryDataSource: AnyObject {
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ())
}

protocol CurExServicesDataSource: AnyObject {
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ())
}

/// Перечисление моковых json
/// - success: Положительный ответ
/// - empty: Ссписок пуст
enum CurExJsonMockType {
    case success, empty, error
    
    /// Метод для получения названия json файла
    ///
    /// - Returns: Название ввиде текста
    func getNameFile() -> String {
        switch(self) {
            case .success: return "CurExSuccess"
            case .empty: return "CurExEmpty"
            case .error: return "CurExError"
        }
    }
}

struct CurExViewModel {
    let text: String
    
    init(_ model: CurExModel) {
        self.text = model.content.text
    }
}

struct CurExModel {
    var content: Content
    
    struct Content {
        var text: String
        
        init(_ text: String) {
            self.text = text
        }
        
        mutating func logic() {
            self.text = text + " " + "bussiness logic"
        }
    }
    
    init(_ content: CurExModel.Content) {
        self.content = content
    }
}

struct CurExRequestModel: Encodable {
    var parameter: Int
}

struct CurExResponseModel: Decodable {
    let status: String
    let content: Response?
    let error: Error?
    
    struct Response: Decodable {
        let text: String
    }
    
    struct Error: Decodable {
        let reason: String
        let code: Int
    }
}
