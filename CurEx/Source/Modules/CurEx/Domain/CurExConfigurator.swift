//
//  CurExCurExConfigurator.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import Foundation

class CurExConfigurator {

    private var presenter: CurExPresenterDataSource!
    
    init() {
        //let dataServices = CurExMockServices(.success)
        let dataServices = CurExNetworkServices()
        let repository = CurExRepository(dataSource: dataServices)
        let interactor = CurExInteractor(dataSource: repository)
        self.presenter = CurExPresenter(dataSource: interactor)
    }
    
    func getDataSource() -> CurExPresenterDataSource {
        return self.presenter
    }
    
}
