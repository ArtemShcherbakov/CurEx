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
        self.dataSource?.getInfo(successful: { model in
            var model = model
            model.content.logic()
            self.viewer?.response(model)
        }, failure: { error in
            self.viewer?.response(error)
        })
    }
}
