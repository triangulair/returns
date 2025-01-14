//
//  Account.swift
//  Returns (macOS)
//
//  Created by James Chen on 2021/11/03.
//

import Foundation
import CoreData

class Account: NSManagedObject, Codable {
    enum CodingKeys: CodingKey {
        case name, createdAt, records
    }

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        records = try container.decode(Set<Record>.self, forKey: .records) as NSSet
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(records as! Set<Record>, forKey: .records)
    }
}

extension Account {
    // Records sorted by date, excluding those out of portfolio start...current date.
    var sortedRecords: [Record] {
        let firstMonth = firstRecordMonth
        let lastMonth = Date().startOfMonth
        let set = records as? Set<Record> ?? []
        return set
            .filter {
                $0.timestamp! >= firstMonth && $0.timestamp! <= lastMonth
            }
            .sorted {
                $0.timestamp! < $1.timestamp!
            }
    }

    // First record month is the month before portfolio start date, to keep
    // the opening balance for the portfolio account.
    private var firstRecordMonth: Date {
        guard let portfolio = portfolio else { return Date().startOfMonth }

        return Calendar.utc.date(byAdding: .month, value: -1, to: portfolio.since.startOfMonth)!
    }

    func rebuildRecords() {
        if portfolio == nil {
            return
        }

        let existing = sortedRecords
        let end = Date().startOfMonth
        var month = firstRecordMonth
        while month <= end {
            // Check if record for this month aleady exists
            if !existing.contains(where: { $0.timestamp == month.startOfMonth }) {
                let record = Record(context: managedObjectContext!)
                record.touch(date: month)
                record.account = self
            }

            month = Calendar.utc.date(byAdding: .day, value: 1, to: month)!
        }
    }
}

extension Account {
    var tag: String {
        "account-" + objectID.uriRepresentation().absoluteString
    }
}
