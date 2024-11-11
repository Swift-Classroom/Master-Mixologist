import Testing
@testable import MasterMixologist

typealias DrinkTrack = (first: String, last: String, total: Int)?

struct MasterMixologistTests {
    
    func checkTest(e: DrinkTrack, g: DrinkTrack) -> Bool {
        guard let expected = e, let got = g else { return e == nil && g == nil }
        return expected.first == got.first && expected.last == got.last && expected.total == got.total
    }
    
    let orders = [
        ["beer"], ["water"], ["soda"], ["shot"], ["mixed drink"], ["fancy drink"], ["frozen drink"],
        ["beer", "shot", "fancy drink"],
        ["beer", "shot", "water", "fancy drink", "frozen drink", "fancy drink"],
        ["mixed drink", "water", "soda", "soda", "beer"], Array(repeating: "frozen drink", count: 10),
    ]
    
    func testTimeToPrepare() {
        #expect([0.5, 0.5, 0.5, 1, 1.5, 2.5, 3, 4, 10, 3.5, 30] == orders.map(timeToPrepare))
    }
    
    func testMakeWedges() throws {
        let got = makeWedges(
            needed: 42, limes: ["small", "large", "large", "medium", "small", "large", "large"])
        #expect(got == 6)
    }
    
    func testMakeWedgesNoNeed() throws {
        let got = makeWedges(
            needed: 0, limes: ["small", "large", "large", "medium", "small", "large", "large"])
        #expect(got == 0)
    }
    
    func testMakeWedgesNoLimes() throws {
        let got = makeWedges(needed: 42, limes: [])
        #expect(got == 0)
    }
    
    func testMakeWedgesTooFewLimes() throws {
        let got = makeWedges(
            needed: 80, limes: ["small", "large", "large", "medium", "small", "large", "large"])
        #expect(got == 7)
    }
    
    func testFinishShift() throws {
        let got = finishShift(minutesLeft: 12, remainingOrders: orders)
        let expected = Array(orders.dropFirst(8))
        #expect(got == expected,
                "You were expected to leave the orders \(expected) for the next shift; you left \(got).")
    }
    
    func testFinishShiftJustRunOver() throws {
        
        let got = finishShift(minutesLeft: 30, remainingOrders: orders)
        let expected: [[String]] = []
        #expect(
            got == expected,
            "You were expected to leave the orders \(expected) for the next shift; you left \(got).")
    }
    
    func testFinishShiftLeaveEarly() throws {
        
        let got = finishShift(minutesLeft: 120, remainingOrders: orders)
        let expected: [[String]] = []
        #expect(
            got == expected,
            "You were expected to leave the orders \(expected) for the next shift; you left \(got).")
    }
    
    func testOrderTracker() throws {
        
        let orders = [
            (drink: "beer", time: "10:01"), (drink: "soda", time: "10:02"),
            (drink: "shot", time: "10:05"), (drink: "fancy drink", time: "10:06"),
            (drink: "soda", time: "10:09"), (drink: "beer", time: "10:15"),
            (drink: "beer", time: "10:22"), (drink: "water", time: "10:26"),
            (drink: "beer", time: "10:28"), (drink: "soda", time: "10:33"),
        ]
        let expectedBeers: DrinkTrack = (first: "10:01", last: "10:28", total: 4)
        let expectedSodas: DrinkTrack = (first: "10:02", last: "10:33", total: 3)
        let got = orderTracker(orders: orders)
        #expect(
            checkTest(e: expectedBeers, g: got.beer) && checkTest(e: expectedSodas, g: got.soda) == true,
            "Expected (beer: \(expectedBeers!), soda: \(expectedSodas!)), got: \(got)")
    }
    
    func testOrderOneEach() throws {
        
        let orders = [
            (drink: "beer", time: "10:01"), (drink: "soda", time: "10:02"),
            (drink: "shot", time: "10:05"), (drink: "fancy drink", time: "10:06"),
            (drink: "water", time: "10:26"),
        ]
        let expectedBeers: DrinkTrack = (first: "10:01", last: "10:01", total: 1)
        let expectedSodas: DrinkTrack = (first: "10:02", last: "10:02", total: 1)
        let got = orderTracker(orders: orders)
        #expect(
            checkTest(e: expectedBeers, g: got.beer) && checkTest(e: expectedSodas, g: got.soda) == true,
            "Expected (beer: \(expectedBeers!), soda: \(expectedSodas!)), got: \(got)")
    }
    
    func testOrderTrackerNoBeer() throws {
        
        let orders = [
            (drink: "soda", time: "10:02"), (drink: "shot", time: "10:05"),
            (drink: "fancy drink", time: "10:06"), (drink: "soda", time: "10:09"),
            (drink: "water", time: "10:26"), (drink: "soda", time: "10:33"),
        ]
        let expectedBeers: DrinkTrack = nil
        let expectedSodas: DrinkTrack = (first: "10:02", last: "10:33", total: 3)
        let got = orderTracker(orders: orders)
        #expect(
            checkTest(e: expectedBeers, g: got.beer) && checkTest(e: expectedSodas, g: got.soda) == true,
            "Expected (beer: nil, soda: \(expectedSodas!)), got: \(got)")
    }
    
    func testOrderTrackerNoSoda() throws {
        
        let orders = [
            (drink: "beer", time: "10:01"), (drink: "shot", time: "10:05"),
            (drink: "fancy drink", time: "10:06"), (drink: "beer", time: "10:15"),
            (drink: "beer", time: "10:22"), (drink: "water", time: "10:26"),
            (drink: "beer", time: "10:28"),
        ]
        let expectedBeers: DrinkTrack = (first: "10:01", last: "10:28", total: 4)
        let expectedSodas: DrinkTrack = nil
        let got = orderTracker(orders: orders)
        #expect(
            checkTest(e: expectedBeers, g: got.beer) && checkTest(e: expectedSodas, g: got.soda) == true,
            "Expected (beer: \(expectedBeers!), soda: nil), got: \(got)")
    }
    
    func testOrderTrackerNils() throws {
        
        let orders = [(drink: String, time: String)]()
        let expectedBeers: DrinkTrack = nil
        let expectedSodas: DrinkTrack = nil
        let got = orderTracker(orders: orders)
        #expect(
            checkTest(e: expectedBeers, g: got.beer) && checkTest(e: expectedSodas, g: got.soda) == true,
            "Expected (beer: nil, soda: nil), got: \(got)")
    }
}
