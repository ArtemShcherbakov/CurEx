//
//  CurExCurExPresenter.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import Foundation

class CurExPresenter {

    private weak var viewer: CurExViewViewer?
    private var dataSource: CurExInteractorDataSource!

    init(dataSource interactor: CurExInteractorDataSource?) {
        self.dataSource = interactor
    }

    private func mappingViewModel(_ model: CurExModel) -> CurExViewModel {

        return CurExViewModel(model)
    }

    deinit {
        print("deinit presenter")
    }

}

extension CurExPresenter: CurExPresenterDataSource {
    func fetch(objectFor view: CurExViewViewer) {
        self.viewer = view
        self.dataSource?.fetch(objectFor: self)
    }
}

extension CurExPresenter: CurExPresenterViewer {
    func response(_ model: CurExModel) {
        let viewModel = mappingViewModel(model)
        self.viewer?.response(viewModel)
    }
    
    func response(_ error: NSError) {
        self.viewer?.response(error)
    }
}
