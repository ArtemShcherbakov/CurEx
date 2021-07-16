//
//  CurExCurExView.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExView: UIViewController {

    private var dataSource: CurExPresenterDataSource?

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Clean")

        self.dataSource = CurExConfigurator().getDataSource()
        self.dataSource?.fetch(objectFor: self)
    }

    deinit {
        print("deinit view")
    }
    
}

extension CurExView: CurExViewViewer {
    func response(_ viewModel: CurExViewModel) {
        print(viewModel.text)
    }

    func response(_ error: NSError) {
        print(error.userInfo["reason"] ?? "")
    }
}
