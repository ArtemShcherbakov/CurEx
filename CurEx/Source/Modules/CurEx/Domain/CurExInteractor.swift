//
//  CurExCurExInteractor.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExInteractor {

    private weak var viewer: CurExPresenterViewer?
    private var dataSource: CurExRepositoryDataSource!
    private var savedModel: CurExModel!

    init(dataSource repository: CurExRepositoryDataSource?) {
        self.dataSource = repository
    }

    deinit {
        print("deinit interactor")
    }
}

extension CurExInteractor: CurExInteractorDataSource {
    func fetch(objectFor presenter: CurExPresenterViewer) {
        // Наблюдателем является презентер
        self.viewer = presenter
        // Вызывается метод репозитория getInfo
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
    }
    
    func nextCurrency(objectFor presenter: CurExPresenterViewer, block: Int) {
        self.viewer = presenter
        self.savedModel.content.nextCurrency(block: block)
        self.viewer?.response(self.savedModel)
    }
    
    func previousCurrency(objectFor presenter: CurExPresenterViewer, block: Int) {
        self.viewer = presenter
        self.savedModel.content.previousCurrency(block: block)
        self.viewer?.response(self.savedModel)
    }
    
    func updateSecondCurrencyValue(objectFor presenter: CurExPresenterViewer, value: String) {
        self.viewer = presenter
        self.savedModel.content.updateSecondCurrencyValue(value: value)
        self.viewer?.response(self.savedModel)
    }
}
