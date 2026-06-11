//
//  GlimpseTests.swift
//  Glimpse
//
//  Created by Nazar Kozak on 11.06.2026.
//

import Testing
@testable import Glimpse

@Suite("Tag parsing")
struct TagParsingTests {
    @Test("Splits on commas and newlines, trims, caps to max")
    func parse() {
        let tags = Glimpse.parseTags("dog, grass ,  frisbee\npark, , sky", max: 3)
        #expect(tags == ["dog", "grass", "frisbee"])
    }

    @Test("Empty output yields no tags")
    func empty() {
        #expect(Glimpse.parseTags("   \n , ", max: 8).isEmpty)
    }
}
