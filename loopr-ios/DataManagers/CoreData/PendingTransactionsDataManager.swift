//
//  PendingTransactionsDataManager.swift
//  loopr-ios
//
//  Created by xiaoruby on 6/2/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import CoreData

class PendingTransactionsDataManager {
    
    final let entityPendingTransactions = "PendingTransactions"
    
    static let shared = PendingTransactionsDataManager()
    private var objects: [NSManagedObject]

    private init() {
        objects = []
    }

    func insert(txHash: String, from: String, to: String, txType: Transaction.TxType, amount: String) {
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityPendingTransactions, in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // set values
        object.setValue(txHash, forKeyPath: "txHash")
        object.setValue(from, forKeyPath: "from")
        object.setValue(to, forKeyPath: "to")
        object.setValue(txType, forKey: "txType")
        object.setValue(amount, forKey: "amount")

        do {
            try managedContext.save()
            objects.append(object)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func selectAll() {
        let managedContext = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityPendingTransactions)
        do {
            objects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
