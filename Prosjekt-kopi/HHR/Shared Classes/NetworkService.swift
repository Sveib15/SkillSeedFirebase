//
//  NetworkService.swift
//  HHR
//
//  Created by Anders Berntsen on 19.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import Foundation

class NetworkService {
    
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    
    let url: URL
    init(url: URL) {
        self.url = url
    }
    
    func downloadImage(completion: @escaping ((NSData) -> Void)) {
        let request = URLRequest(url: self.url)
        let datatask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    switch (httpResponse.statusCode) {
                    case 200:
                        if let data = data {
                            completion(data as NSData)
                        }
                    default:
                        print(httpResponse.statusCode)
                    }
                }
                
            } else {
                print("there was error \(error?.localizedDescription ?? "oops")")
            }
        }
        datatask.resume()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

