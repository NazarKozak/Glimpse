//
//  OnDeviceVLMTests.swift
//  OnDeviceVLM
//
//  Created by Nazar Kozak on 11.06.2026.
//

import Testing
@testable import OnDeviceVLMSDK

@Suite("Tag parsing")
struct TagParsingTests {
    @Test("Splits on commas and newlines, trims, caps to max")
    func parse() {
        let tags = OnDeviceVLM.parseTags("dog, grass ,  frisbee\npark, , sky", max: 3)
        #expect(tags == ["dog", "grass", "frisbee"])
    }

    @Test("Empty output yields no tags")
    func empty() {
        #expect(OnDeviceVLM.parseTags("   \n , ", max: 8).isEmpty)
    }
}
