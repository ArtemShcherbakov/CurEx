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
    func exchangePressed()
    func saveWalletsToUserDefaults()
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
    func exchangeCurrency(objectFor presenter: CurExPresenterViewer)
    func saveWalletsToUserDefaults(objectFor presenter: CurExPresenterViewer)
    func isConnectedToNetwork() -> Bool
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
    
    let debited: String
    let credited: String
    
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
        self.debited = model.content.debited
        self.credited = model.content.credited
        
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
        
        var usdWallet = 100.0
        var eurWallet = 100.0
        var gbpWallet = 100.0
        var upperWallet = 100.0
        var lowerWallet = 100.0
        
        var debited = ""
        var credited = ""
        
        var upperCurrency = "USD"
        var lowerCurrency = "USD"
        var upperSymbol = "$"
        var lowerSymbol = "$"
        var upperRate = 1.0
        var lowerRate = 1.0
        var upperValue = ""
        var lowerValue = ""
        
        init(_ event: String, usd: Double, eur: Double, gbp: Double) {
            self.event = event
            self.usd = usd
            self.eur = eur
            self.gbp = gbp
            self.getWalletsFromUserDefaults()
        }
        
        mutating func getWalletsFromUserDefaults() {
            let usdWalletString = UserDefaults.standard.string(forKey: "usdWallet")
            let eurWalletString = UserDefaults.standard.string(forKey: "eurWallet")
            let gbpWalletString = UserDefaults.standard.string(forKey: "gbpWallet")
            self.usdWallet = usdWalletString == nil ? 100.0 : Double(usdWalletString!)!
            self.eurWallet = eurWalletString == nil ? 100.0 : Double(eurWalletString!)!
            self.gbpWallet = gbpWalletString == nil ? 100.0 : Double(gbpWalletString!)!
            upperWallet = usdWallet
            lowerWallet = usdWallet
        }
        
        mutating func realRates() -> [Double] {
            let upper = self.upperCurrency
            let lower = self.lowerCurrency
            if upper == "EUR" && lower == "USD" { return [rounder(usd), rounder(eur / usd)] }
            if upper == "EUR" && lower == "GBP" { return [rounder(gbp), rounder(eur / gbp)] }
            if upper == "USD" && lower == "EUR" { return [rounder(eur / usd), rounder(usd)] }
            if upper == "USD" && lower == "GBP" { return [rounder(gbp / usd), rounder(usd / gbp)] }
            if upper == "GBP" && lower == "USD" { return [rounder(usd / gbp), rounder(gbp / usd)] }
            if upper == "GBP" && lower == "EUR" { return [rounder(eur / gbp), rounder(gbp)] }
            return [1.0, 1.0]
        }
        
        mutating func nextCurrency(block: Int) {
            var currency = block == 1 ? self.upperCurrency : self.lowerCurrency
            var symbol = ""
            var wallet = 0.0
            switch currency {
                case "USD" : currency = "EUR"; symbol = "€"; wallet = self.eurWallet
                case "EUR" : currency = "GBP" ; symbol = "£" ; wallet = self.gbpWallet
                case "GBP" : currency = "USD" ; symbol = "$" ; wallet = self.usdWallet
                default : print("Неизвестная валюта")
            }
            if block == 1 { self.upperCurrency = currency; self.upperSymbol = symbol; self.upperWallet = wallet }
            if block == 2 { self.lowerCurrency = currency; self.lowerSymbol = symbol; self.lowerWallet = wallet }
            upperRate = self.realRates()[0]
            lowerRate = self.realRates()[1]
            self.updateSecondCurrencyValue(value: self.upperValue)
            self.event = "next"
        }
        
        mutating func previousCurrency(block: Int) {
            var currency = block == 1 ? self.upperCurrency : self.lowerCurrency
            var symbol = ""
            var wallet = 0.0
            switch currency {
                case "USD" : currency = "GBP" ; symbol = "£" ; wallet = self.gbpWallet
                case "EUR" : currency = "USD" ; symbol = "$" ; wallet = self.usdWallet
                case "GBP" : currency = "EUR" ; symbol = "€" ; wallet = self.eurWallet
                default : print("Неизвестная валюта")
            }
            if block == 1 { self.upperCurrency = currency; self.upperSymbol = symbol; self.upperWallet = wallet }
            if block == 2 { self.lowerCurrency = currency; self.lowerSymbol = symbol; self.lowerWallet = wallet }
            upperRate = self.realRates()[0]
            lowerRate = self.realRates()[1]
            self.updateSecondCurrencyValue(value: self.upperValue)
            self.event = "previous"
        }
        
        mutating func updateSecondCurrencyValue(value: String) {
            let formatted = value.count > 5 ?  String(value[..<value.index(value.startIndex, offsetBy: 5)]) : value
            let noCommaValue = formatted.replacingOccurrences(of: ",", with: ".")
            let doubleValue = Double(noCommaValue) ?? 0.00
            let secondValue = rounder(doubleValue * upperRate)
            if secondValue != 0.00 {
                self.lowerValue = String(secondValue)
            } else {
                self.lowerValue = ""
            }
            self.upperValue = noCommaValue
            self.event = "value"
        }
        
        mutating func exchangeCurrency() {
            if upperValue == "" || upperValue == "." || upperValue.components(separatedBy: ".").count > 2  {
                // Поле пустое или заполнено неправильно
                self.event = "emptyfield"
                return
            }
            if self.upperWallet < Double(self.upperValue)! {
                // Недостаточно средств
                self.event = "nomoney"
                return
            }
            if upperCurrency == lowerCurrency {
                // Обмен одинаковых валют
            } else {
                // Обмен разных валют
                self.upperWallet = rounder(upperWallet - Double(self.upperValue)!)
                self.lowerWallet = rounder(lowerWallet + Double(self.lowerValue)!)
                switch self.upperCurrency {
                case "USD" : usdWallet = upperWallet
                case "EUR" : eurWallet = upperWallet
                case "GBP" : gbpWallet = upperWallet
                default : print("Неизвестная валюта")
                }
                switch self.lowerCurrency {
                case "USD" : usdWallet = lowerWallet
                case "EUR" : eurWallet = lowerWallet
                case "GBP" : gbpWallet = lowerWallet
                default : print("Неизвестная валюта")
                }
            }
            self.credited = self.upperValue
            self.debited = self.lowerValue
            self.upperValue = ""
            self.lowerValue = ""
            self.event = "exchange"
        }
        
        mutating func saveWalletsToUserDefaults() {
            self.event = "background"
            UserDefaults.standard.set(String(self.usdWallet), forKey: "usdWallet")
            UserDefaults.standard.set(String(self.eurWallet), forKey: "eurWallet")
            UserDefaults.standard.set(String(self.gbpWallet), forKey: "gbpWallet")
        }
        
        func rounder(_ value: Double) -> Double {
            return round(100 * value) / 100
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
