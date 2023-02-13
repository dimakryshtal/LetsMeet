//
//  Date + Extensions.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 13.02.2023.
//

import Foundation

extension Date {
    func onlyDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: self)
    }
    
    static func calculateCurrentAge(birthDate: String) -> Int{
        let currentDate = Date().onlyDate().split(separator: "-").map({Int($0)!})
        let birthDate = birthDate.split(separator: "-").map({Int($0)!})
        
        var age = currentDate[0] - birthDate[0] - 1
        if currentDate[1] < birthDate[1] {
            return age
        } else if currentDate[1] > birthDate[1] {
            age += 1
            return age
        }
        
        if currentDate[2] >= birthDate[2] {
            age += 1
        }
        
        return age
    }
    
}

