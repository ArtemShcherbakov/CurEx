//
//  CurExCurExInteractor.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit
import SystemConfiguration

class CurExInteractor {

    private weak var viewer: CurExPresenterViewer?
    private var dataSource: CurExRepositoryDataSource!
    private var savedModel: CurExModel!
    // Я точно не уверен, что правильно сохранять модель в интеракторе
    // Но, подумав о том, что и модель и интерактор находятся в слое Domain, я все-же сделал это

    init(dataSource repository: CurExRepositoryDataSource?) {
        self.dataSource = repository
    }

    deinit {
        print("deinit interactor")
    }
}

extension CurExInteractor: CurExInteractorDataSource {
    func fetch(objectFor presenter: CurExPresenterViewer) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.dataSource?.getInfo(successful: { model in
                if self.savedModel == nil {
                    self.savedModel = model
                } else {
                    self.savedModel.content.event =  model.content.event
                    self.savedModel.content.usd = model.content.usd
                    self.savedModel.content.eur = model.content.eur
                    self.savedModel.content.gbp = model.content.gbp
                }
                self.viewer?.response(self.savedModel)
            }, failure: { error in
                self.viewer?.response(error)
            })
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    
    func nextCurrency(objectFor presenter: CurExPresenterViewer, block: Int) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.savedModel.content.nextCurrency(block: block)
            self.viewer?.response(self.savedModel)
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    
    func previousCurrency(objectFor presenter: CurExPresenterViewer, block: Int) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.savedModel.content.previousCurrency(block: block)
            self.viewer?.response(self.savedModel)
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    
    func updateSecondCurrencyValue(objectFor presenter: CurExPresenterViewer, value: String) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.savedModel.content.updateSecondCurrencyValue(value: value)
            self.viewer?.response(self.savedModel)
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    
    func exchangeCurrency(objectFor presenter: CurExPresenterViewer) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.savedModel.content.exchangeCurrency()
            self.viewer?.response(self.savedModel)
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    
    func saveWalletsToUserDefaults(objectFor presenter: CurExPresenterViewer) {
        self.viewer = presenter
        if isConnectedToNetwork() {
            self.savedModel.content.saveWalletsToUserDefaults()
            self.viewer?.response(self.savedModel)
        } else {
            self.viewer?.response(CurExModel(CurExModel.Content("disconnected", usd: 0, eur: 0, gbp: 0)))
        }
    }
    func isConnectedToNetwork() -> Bool {
        // В своих проектах я обычно использовал Network, но он работает только начиная с iOS 12
        // Поэтому я нагуглил и применил это решение, чтобы не было крэша при отсутствии интернета
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
}
