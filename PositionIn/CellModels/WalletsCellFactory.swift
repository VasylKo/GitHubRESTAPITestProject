//
//  WalletsCellFactory.swift
//  PositionIn
//
//  Created by Ruslan Kolchakov on 04/03/16.
//  Copyright (c) 2016 Soluna Labs. All rights reserved.
//

import PosInCore
import CleanroomLogger

struct WalletsCellFactory {
    func walletReuseIdForModel(model: TableViewCellModel) -> String {
        return EventListCell.reuseId()
    }
    
    func walletReuseId() -> [String]  {
        return [EventListCell.reuseId()]
    }

    func walletModelsForItem(order: Order) -> [TableViewCellModel] {
        return [
            ComapctBadgeFeedTableCellModel (
                delegate: nil,
                item: order,
                title: order.entityDetails?.name,
                details: AppConfiguration().currencyFormatter.stringFromNumber(order.price ?? 0.0) ?? "",
                info: order.paymentDate?.formattedAsTimeAgo() ?? "",
                text: "",
                imageURL: order.entityDetails?.imageURL,
                avatarURL: nil,
                badge: "",
                data: order.paymentDate
            ),
        ]
    }
}
