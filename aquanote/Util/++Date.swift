//
//  ++Date.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import Foundation

extension Date {
    
    enum DateStringFormat {
        /// "yyyy년 MM월 dd일"
        case kr// = "yyyy년 MM월 dd일"
        /// "yyyy.MM.dd"
        case simple// = "yyyy.MM.dd"
        /// "yyyy.MM.dd a HH:mm"
        case full// = "yyyy.MM.dd a HH:mm"
        /// customize format
        case custom(String)
    }
    
    func toKRString(format: DateStringFormat = .kr) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        switch format {
        case .kr:
            formatter.dateFormat = "yyyy년 MM월 dd일"
        case .simple:
            formatter.dateFormat = "yyyy.MM.dd"
        case .full:
            formatter.dateFormat = "yyyy.MM.dd a HH:mm"
        case .custom(let string):
            formatter.dateFormat = string
        }
        return formatter.string(from: self)
    }
}

extension String {
    func toDate(format: Date.DateStringFormat) -> Date? {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        switch format {
        case .kr:
            formatter.dateFormat = "yyyy년 MM월 dd일"
        case .simple:
            formatter.dateFormat = "yyyy.MM.dd"
        case .full:
            formatter.dateFormat = "yyyy.MM.dd a HH:mm"
        case .custom(let string):
            formatter.dateFormat = string
        }
        return formatter.date(from: self)
    }
}
