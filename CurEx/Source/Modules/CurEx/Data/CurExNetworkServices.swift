//
//  CurExCurExNetworkServices.swift
//  CurEx
//
//  Created by Artem Shcherbakov on 16/07/2021.
//  Copyright © 2021 BLANC. All rights reserved.
//

import UIKit

class CurExNetworkServices: CurExServicesDataSource {
    
    func getInfo(successful: @escaping (CurExModel) -> (), failure: (NSError) -> ()) {
        let url = URL(string: "http://api.exchangeratesapi.io/v1/latest?access_key=c6e1cbaad8bae44363f35914c791f30b&symbols=USD,EUR,GBP&format=1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let rates = json["rates"] as? [String: Double] {
                        let USD = rates["USD"] ?? 1.0
                        let EUR = rates["EUR"] ?? 1.0
                        let GPB = rates["GBP"] ?? 1.0
                        let model = CurExModel(CurExModel.Content("update", usd: USD, eur: EUR, gbp: GPB))
                        successful(model)
                        return
                    }
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
