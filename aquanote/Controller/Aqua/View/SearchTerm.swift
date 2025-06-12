//
//  File.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit

struct SearchTerm: UIContentConfiguration, Equatable, Encodable, Decodable {
    var id: UUID = UUID()
    var date: Date = Date(timeIntervalSince1970: .zero)
    var keyword: String = ""
    var selected: Bool = false
    var validation: Int = 1

    func makeContentView() -> UIView & UIContentView {
        return SearchTermContentView(with: self)
    }
    
    
    func updated(for state: UIConfigurationState) -> SearchTerm {
        guard let state = state as? UICellConfigurationState else { return self }
        var newState = self
        newState.selected = state.isSelected
        return newState
    }
}

