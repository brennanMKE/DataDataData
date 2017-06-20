//
//  Environment.swift
//  DataDataData
//
//  Created by Stehling, Brennan on 6/20/17.
//  Copyright © 2017 Acme. All rights reserved.
//

import Foundation

public struct Environment {
    
    /** Get a named string value. */
    static func stringValueForEnvironmentVariable(_ name: String) -> String {
        return ProcessInfo.processInfo.environment[name]?.uppercased() ?? ""
    }
    
    /** Get a named boolean value. */
    static func boolValueForEnvironmentVariable(_ name: String) -> Bool {
        return ProcessInfo.processInfo.environment[name]?.uppercased() == "YES"
    }
    
}
