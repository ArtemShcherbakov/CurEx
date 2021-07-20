//
//  CurExCurExRepository.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExRepository {

    private var dataSource: CurExServicesDataSource!

    init(dataSource services: CurExServicesDataSource?) {
        self.dataSource = services
    }

    deinit {
        print("deinit repository")
    }
}

extension CurExRepository: CurExRepositoryDataSource {
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ()) {
        self.dataSource?.getInfo(successful: successful, failure: failure)
    }
}
