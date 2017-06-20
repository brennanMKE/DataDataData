//
//  DataStore.swift
//  DataDataData
//
//  Created by Stehling, Brennan on 6/20/17.
//  Copyright © 2017 Acme. All rights reserved.
//


import Foundation
import CoreData

/// Data Store type
///
/// - SQL: SQLite
/// - Memory: Memory
enum DataStoreType {
    case sql
    case memory
}

/// Sort Order
///
/// - Ascending: ascending
/// - Descending: descending
enum SortOrder {
    case ascending
    case descending
}

let DefaultPageSize: Int = 10

// Locally used constants
fileprivate let LocalDataName = "LocalData"
fileprivate let LocalDataSqliteName = "LocalData.sqlite"

class DataStore {
    
    // MARK: - Properties -
    
    fileprivate let dataStoreType: DataStoreType
    
    fileprivate static var dataStores : [DataStoreType:DataStore] = [:]
    
    fileprivate init() {
        // nothing to initialize
        dataStoreType = DataStore.inMemory ? .memory : .sql
    }
    
    fileprivate init(dataStoreType: DataStoreType) {
        self.dataStoreType = dataStoreType
    }
    
    /// Indicates if the data store is only operating in memory.
    static var inMemory: Bool {
        return Environment.boolValueForEnvironmentVariable("CoreDataInMemoryOnly")
    }
    
    /// Default data store.
    ///
    /// - Returns: data store
    static func dataStore() -> DataStore {
        let dataStoreType: DataStoreType = DataStore.inMemory ? .memory : .sql
        return dataStore(dataStoreType)
    }
    
    /// Data Store factory to access singleton value for the given type.
    ///
    /// - Parameter dataStoreType: type
    /// - Returns: data store
    static func dataStore(_ dataStoreType: DataStoreType) -> DataStore {
        if let dataStore = dataStores[dataStoreType] {
            return dataStore
        }
        else {
            let dataStore = DataStore(dataStoreType: dataStoreType)
            dataStores[dataStoreType] = dataStore
            return dataStore
        }
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            }
            catch {
                // TODO: Log error
            }
        }
    }
    
    // MARK: - Public Core Data Stack -
    
    /// Managed Object Context for Core Data
    ///
    /// See: [Core Data](https://developer.apple.com/library/content/documentation/DataManagement/Devpedia-CoreData/managedObjectContext.html)
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    // MARK: - Private Core Data Stack -
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError()
        }
        return directoryURL
    }()
    
    fileprivate lazy var managedObjectModel : NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: LocalDataName, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError()
        }
        return mom
    }()
    
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Why is the custom migration policy not running?
        // https://stackoverflow.com/questions/3651805/nsentitymigrationpolicy-subclass-methods-not-being-called
        
        do {
            let options: [String : Any] = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption : false,
                NSPersistentStoreFileProtectionKey : FileProtectionType.completeUntilFirstUserAuthentication
            ]
            
            if self.dataStoreType == .memory {
                try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: options)
            }
            else {
                let sqliteURL = self.applicationDocumentsDirectory.appendingPathComponent(LocalDataSqliteName)
                if Environment.boolValueForEnvironmentVariable("CoreDataReset") {
                    // Delete LocalData.sqlite if reset if requested
                    if FileManager.default.fileExists(atPath: sqliteURL.path) {
                        do {
                            try FileManager.default.removeItem(atPath: sqliteURL.path)
                        }
                        catch {
                            // TODO: Log error
                        }
                    }
                }
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: options)
            }
        }
        catch {
            // TODO: Log error
            fatalError("Unable to Load Persistent Store")
        }
        
        return coordinator
    }()
    
}

extension NSManagedObject {
    
    /// Core Data Object Name
    public static var objectName: String {
        return String(describing: self)
    }
    
}

