//
//  HHRTests.swift
//  HHRTests
//
//  Created by Anders Berntsen on 15.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import XCTest
@testable import HHR

class HHRTests: XCTestCase {
    
    func testCheckDescLenght() {
        let per = InitialDescView()
        let testText = "Test Text"
        let testLength = 6
        
        XCTAssertFalse(per.checkDescLenght(text: testText, length: testLength))
        }
    
    func testCheckDescTrue() {
        let per = InitialDescView()
        XCTAssertTrue(per.checkDescLenght(text: "This is another test", length: 30))

    }
}


