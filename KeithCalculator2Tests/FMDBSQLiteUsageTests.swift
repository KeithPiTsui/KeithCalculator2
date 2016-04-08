//
//  FMDBSQLiteUsageTests.swift
//  KeithCalculator2
//
//  Created by Pi on 4/4/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import XCTest

class FMDBSQLiteUsageTests: XCTestCase {
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    /**
     Call this test function to evaluate whether or not the fmdb framework has been setup correctly
     */
    
    func testFMDBConfigure() {
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("test.sqlite")
        
        let database = FMDatabase(path: fileURL.path)
        
        if !database.open() {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("drop table if exists test", values: nil)
            try database.executeUpdate("create table if not exists test(x text, y text, z text)", values: nil)
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["a", "b", "c"])
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["e", "f", "g"])
            
            let rs = try database.executeQuery("select x, y, z from test", values: nil)
            while rs.next() {
                let x = rs.stringForColumn("x")
                let y = rs.stringForColumn("y")
                let z = rs.stringForColumn("z")
                //print("x = \(x); y = \(y); z = \(z)")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
}
