//
//  SortInfo.swift
//  TemplateOfDealsViewer
//
//  Created by Stepan Ostapenko on 11.02.2024.
//

struct SortInfo {
    enum DealSortingType: CustomStringConvertible, CaseIterable {
        case Price
        case Amount
        case Name
        case Date
        case Side
        
        var description: String {
            switch self {
            case .Price:
                "Price"
            case .Amount:
                "Amount"
            case .Name:
                "Instrument"
            case .Date:
                "Date"
            case .Side:
                "Side"
            }
        }
    }
    
    enum SortOrder {
        case Ascending
        case Descending
        
        var sortOrderSystemImage: String {
            switch self {
            case .Ascending:
                "arrowtriangle.up.circle"
            case .Descending:
                "arrowtriangle.down.circle"
            }
        }
    }
    
    var type: DealSortingType
    var order: SortOrder
}

