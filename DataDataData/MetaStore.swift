//
//  MetaStore.swift
//  DataDataData
//
//  Created by Stehling, Brennan on 6/20/17.
//  Copyright © 2017 Acme. All rights reserved.
//

import Foundation
import CoreData

struct MetaStore {
    
    // MARK: - Properties -
    
    let dataStore: DataStore
    
    // MARK: - Initialization -
    
    /// Initializion with default data store.
    init() {
        dataStore = DataStore.dataStore()
    }
    
    /// Initialization using a Data Store Type.
    ///
    /// - Parameter dataStoreType: type
    init(dataStoreType: DataStoreType) {
        dataStore = DataStore.dataStore(dataStoreType)
    }
    
    func createMeta(field1: Int16, field2: Double, field3: String?, field4: Int64, field5: Bool) -> Meta {
        guard let meta = NSEntityDescription.insertNewObject(forEntityName: Meta.objectName, into: dataStore.managedObjectContext) as? Meta else {
            fatalError("Failed to create instance of Meta.")
        }
        
        meta.field1 = field1
        meta.field2 = field2
        meta.field3 = field3
        meta.field4 = field4
        meta.field5 = field5
        meta.created = Date()
        
        return meta
    }
    
    func fetchMeta() -> [Meta]? {
        let request: NSFetchRequest<Meta> = Meta.fetchRequest()
        let moc = DataStore.dataStore().managedObjectContext
        let metas = try? moc.fetch(request)
        return metas
    }
    
    func populateMeta() -> [Meta] {
        if let metas = fetchMeta(), metas.count > 0 {
            return metas
        }
        
        let metas = [
            createMeta(field1: 0, field2: 0.0, field3: "", field4: 0, field5: false),
            createMeta(field1: 1, field2: 1.1, field3: "meta", field4: 1, field5: true),
            createMeta(field1: Int16.max, field2: Double.greatestFiniteMagnitude, field3: "meta meta meta", field4: Int64.max, field5: true)
        ]
        DataStore.dataStore().saveContext()
        
        return metas
    }
    
}
