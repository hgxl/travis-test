//
//  Utility.swift
//  InAppNotification
//
//  Created by Henri Gil on 07/01/2018.
//  Copyright © 2018 Henri Gil. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        
        contentMode = mode
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.6)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() {
                self.backgroundColor = UIColor.clear
                self.image = image
            }
            }.resume()
    }
    
}

