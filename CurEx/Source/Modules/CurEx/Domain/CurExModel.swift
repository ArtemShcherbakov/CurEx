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
    func swipe(direction: String, block: Int)
    func fieldChanged(value: String)
}

protocol CurExPresenterViewer: AnyObject {
    func response(_ model: CurExModel)
    func response(_ error: NSError)
}

protocol CurExInteractorDataSource: AnyObject {
    func fetch(objectFor presenter: CurExPresenterViewer)
    func nextCurrency(objectFor presenter: CurExPresenterViewer, block: Int)
    func previousCurrency(objectFor presenter: CurExPresenterViewer, block: Int)
    func updateSecondCurrencyValue(objectFor presenter: CurExPresenterViewer, value: String)
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
    let event: String
    
    let upperCurrency: String
    let upperValue: String
    let upperWallet: String
    let upperRate: String
    
    let lowerCurrency: String
    let lowerValue: String
    let lowerWallet: String
    let lowerRate: String
    
    init(_ model: CurExModel) {
        self.event = model.content.event
        
        self.upperCurrency = model.content.upperCurrency
        self.upperValue = model.content.upperValue
        self.upperWallet = "You have: \(model.content.upperWallet)\(model.content.upperSymbol)"
        self.upperRate = "1.0\(model.content.upperSymbol) = \(model.content.upperRate)\(model.content.lowerSymbol)"
        
        self.lowerCurrency = model.content.lowerCurrency
        self.lowerValue = model.content.lowerValue
        self.lowerWallet = "You have: \(model.content.lowerWallet)\(model.content.lowerSymbol)"
        self.lowerRate = "1.0\(model.content.lowerSymbol) = \(model.content.lowerRate)\(model.content.upperSymbol)"
    }
}

struct CurExModel {
    var content: Content
    
    struct Content {
        var event: String
        var usd: Double
        var eur: Double
        var gbp: Double
        
        var upperCurrency = "USD"
        var lowerCurrency = "USD"
        var upperSymbol = "$"
        var lowerSymbol = "$"
        var upperWallet = 100.0
        var lowerWallet = 100.0
        var upperRate = 1.0
        var lowerRate = 1.0
        var upperValue = ""
        var lowerValue = ""
        
        init(_ event: String, usd: Double, eur: Double, gbp: Double) {
            self.event = event
            self.usd = usd
            self.eur = eur
            self.gbp = gbp
        }
        
        mutating func realRates() -> [Double] {
            let upper = self.upperCurrency
            let lower = self.lowerCurrency
            if upper == "USD" && lower == "EUR" { return [round(100 * (eur / usd)) / 100, round(100 * usd) / 100] }
            if upper == "USD" && lower == "GBP" { return [round(100 * (gbp / usd)) / 100, round(100 * (usd / gbp)) / 100] }
            if upper == "EUR" && lower == "USD" { return [round(100 * usd) / 100, round(100 * (eur / usd)) / 100] }
            if upper == "EUR" && lower == "GBP" { return [round(100 * gbp) / 100, round(100 * (eur / gbp)) / 100] }
            if upper == "GBP" && lower == "USD" { return [round(100 * (usd / gbp)) / 100, round(100 * (gbp / usd)) / 100] }
            if upper == "GBP" && lower == "EUR" { return [round(100 * (eur / gbp)) / 100, round(100 * gbp) / 100] }
            return [1.0, 1.0]
        }
        
        mutating func nextCurrency(block: Int) {
            if block == 1 {
                switch self.upperCurrency {
                    case "USD" : self.upperCurrency = "EUR"; self.upperSymbol = "€";
                    case "EUR" : self.upperCurrency = "GBP" ; self.upperSymbol = "£"
                    case "GBP" : self.upperCurrency = "USD" ; self.upperSymbol = "$"
                    default : self.upperCurrency = "USD"
                }
            } else {
                switch self.lowerCurrency {
                    case "USD" : self.lowerCurrency = "EUR" ; self.lowerSymbol = "€"
                    case "EUR" : self.lowerCurrency = "GBP" ; self.lowerSymbol = "£"
                    case "GBP" : self.lowerCurrency = "USD" ; self.lowerSymbol = "$"
                    default : self.lowerCurrency = "USD"
                }
            }
            upperRate = self.realRates()[0]
            lowerRate = self.realRates()[1]
            self.updateSecondCurrencyValue(value: self.upperValue)
            self.event = "next"
        }
        
        mutating func previousCurrency(block: Int) {
            if block == 1 {
                switch self.upperCurrency {
                    case "USD" : self.upperCurrency = "GBP" ; self.upperSymbol = "£"
                    case "EUR" : self.upperCurrency = "USD" ; self.upperSymbol = "$"
                    case "GBP" : self.upperCurrency = "EUR" ; self.upperSymbol = "€"
                    default : self.upperCurrency = "USD"
                }
            } else {
                switch self.lowerCurrency {
                    case "USD" : self.lowerCurrency = "GBP" ; self.lowerSymbol = "£"
                    case "EUR" : self.lowerCurrency = "USD" ; self.lowerSymbol = "$"
                    case "GBP" : self.lowerCurrency = "EUR" ; self.lowerSymbol = "€"
                    default : self.lowerCurrency = "USD"
                }
            }
            upperRate = self.realRates()[0]
            lowerRate = self.realRates()[1]
            self.updateSecondCurrencyValue(value: self.upperValue)
            self.event = "previous"
        }
        
        mutating func updateSecondCurrencyValue(value: String) {
            let noCommaValue = value.replacingOccurrences(of: ",", with: ".")
            let secondValue = round(100 * (Double(noCommaValue) ?? 0.00) * upperRate) / 100
            if secondValue != 0.00 {
                self.lowerValue = String(secondValue)
            } else {
                self.lowerValue = ""
            }
            self.upperValue = noCommaValue
            self.event = "value"
        }
    }
    
    init(_ content: CurExModel.Content) {
        self.content = content
    }
}

struct CurExParseResultModel: Decodable {
    let rates: String
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
