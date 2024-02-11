//
//  Presenter.swift
//  TemplateOfDealsViewer
//
//  Created by Stepan Ostapenko on 10.02.2024.
//

import Foundation
import Combine

class DealSortingsPresenter {
    private let server = Server()
    private(set) var model: [Deal] = []
    private var stack: [Deal] = []
    let formatter = DateFormatter()
    
    var sortInfo: SortInfo = SortInfo(type: .Date, order: .Ascending)
    var bag: [AnyCancellable] = []
    
    private lazy var passSortedDealsSubject = PassthroughSubject<[Deal], Never>()
    lazy var passSortedPublisher = passSortedDealsSubject.eraseToAnyPublisher()
    
    let queue = DispatchQueue(label: "addNewDataQueue",
                                        qos: .userInitiated)
    
    init() {
        formatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
    }
    
    func subscribe(updateUI: @escaping ()->Void) {
        passSortedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { res in
            }, receiveValue: { [weak self] data in
                guard let this = self else { return }
                this.model = data
                updateUI()
            }).store(in: &bag)
        
        server.subscribeToDeals { [weak self] deals in
            guard let this = self else { return }
            
            this.queue.async {
                this.stack.append(contentsOf: deals)
                
                if (this.stack.count >= 1000) {
                    let newData = this.stack.sorted(by: this.getSortDataFunc(sortInfo: this.sortInfo))
                    let data = this.combineSortedArrays(first: this.model, second: newData, sortInfo: this.sortInfo)
                    this.stack.removeAll()
                    this.passSortedDealsSubject.send(data)
                }
            }
        }
    }
    
    
    func changeSortOrder() {
        if (sortInfo.order == .Ascending) {
            sortInfo.order = .Descending
        } else {
            sortInfo.order = .Ascending
        }
        sort(type: sortInfo.type)
    }
    
    func sort(type: SortInfo.DealSortingType) {
        sortInfo = SortInfo(type: type, order: sortInfo.order)
        DispatchQueue.global(qos: .userInteractive).async {
            let data = self.model.sorted(by: self.getSortDataFunc(sortInfo: self.sortInfo))
            self.passSortedDealsSubject.send(data)
        }
    }

    private func getSortDataFunc(sortInfo: SortInfo) -> (Deal, Deal) -> Bool {
        switch sortInfo.type {
        case .Price:
            return { deal1, deal2 in
                sortInfo.order == .Ascending ? deal1.price < deal2.price : deal1.price > deal2.price
            }
        case .Amount:
            return { deal1, deal2 in
                sortInfo.order == .Ascending ? deal1.amount < deal2.amount : deal1.amount > deal2.amount
            }
        case .Name:
            return { deal1, deal2 in
                sortInfo.order == .Ascending ? deal1.instrumentName < deal2.instrumentName : deal1.instrumentName > deal2.instrumentName
            }
        case .Date:
            return { deal1, deal2 in
                sortInfo.order == .Ascending ? deal1.dateModifier < deal2.dateModifier : deal1.dateModifier > deal2.dateModifier
            }
        case .Side:
            return { deal1, deal2 in
                sortInfo.order == .Ascending ? deal1.side < deal2.side : deal1.side > deal2.side
            }
        }
    }
    
    private func combineSortedArrays(first: [Deal], second: [Deal], sortInfo: SortInfo) -> [Deal] {
        var res: [Deal] = []
        var i = 0
        var j = 0
        let resCount = first.count + second.count
        
        while (i < first.count && j < second.count) {
            if (getSortDataFunc(sortInfo: sortInfo)(first[i], second[j])) {
                res.append(first[i])
                i+=1
            } else {
                res.append(second[j])
                j+=1
            }
        }
        
        if (res.count < resCount && i < first.count) {
            res.append(contentsOf: first[i...(resCount - j)-1])
        } else if (res.count < resCount) {
            res.append(contentsOf: second[j...(resCount - i)-1])
        }
        
        return res
    }
}
