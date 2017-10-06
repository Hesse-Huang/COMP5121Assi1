//
//  main.swift
//  kNNForAss1
//
//  Created by Hesse Huang on 2017/10/2.
//  Copyright © 2017年 Hesse. All rights reserved.
//

import Foundation

enum Decision {
    case remain, downgrade, upgrade, tbd
}

struct Record {
    var memberID: Int
    var avaNumOfFlight: Int
    var avaNumOfMilesOfFlight: Double
    var numOfDays: Int
    var decision: Decision
    
    var avaTotalMiles: Double {
        return Double(avaNumOfFlight) * avaNumOfMilesOfFlight
    }
    
    var years: Double {
        return Double(numOfDays) / 365.0
    }
    var numOfFlight: Double {
        return years * Double(avaNumOfFlight)
    }
    var actualTotalMiles: Double {
        return numOfFlight * avaNumOfMilesOfFlight
    }
}

typealias Neighbour = (Record, Double)

var records: [Record] = [
    Record(
        memberID: 1,
        avaNumOfFlight: 29,
        avaNumOfMilesOfFlight: 2921.8,
        numOfDays: 879,
        decision: .remain),
    Record(
        memberID: 2,
        avaNumOfFlight: 62,
        avaNumOfMilesOfFlight: 2867.3,
        numOfDays: 705,
        decision: .downgrade),
    Record(
        memberID: 3,
        avaNumOfFlight: 17,
        avaNumOfMilesOfFlight: 2440.5,
        numOfDays: 929,
        decision: .remain),
    Record(
        memberID: 4,
        avaNumOfFlight: 34,
        avaNumOfMilesOfFlight: 2113.3,
        numOfDays: 223,
        decision: .downgrade),
    Record(
        memberID: 5,
        avaNumOfFlight: 50,
        avaNumOfMilesOfFlight: 2437.8,
        numOfDays: 724,
        decision: .downgrade),
    Record(
        memberID: 6,
        avaNumOfFlight: 11,
        avaNumOfMilesOfFlight: 2187.6,
        numOfDays: 143,
        decision: .upgrade),
    Record(
        memberID: 7,
        avaNumOfFlight: 9,
        avaNumOfMilesOfFlight: 2691.1,
        numOfDays: 1015,
        decision: .upgrade),
    Record(
        memberID: 8,
        avaNumOfFlight: 34,
        avaNumOfMilesOfFlight: 2921.1,
        numOfDays: 335,
        decision: .upgrade),
    Record(
        memberID: 9,
        avaNumOfFlight: 39,
        avaNumOfMilesOfFlight: 1592.3,
        numOfDays: 975,
        decision: .downgrade),
    Record(
        memberID: 10,
        avaNumOfFlight: 73,
        avaNumOfMilesOfFlight: 2804.9,
        numOfDays: 544,
        decision: .upgrade),
    Record(
        memberID: 11,
        avaNumOfFlight: 78,
        avaNumOfMilesOfFlight: 2685.1,
        numOfDays: 84,
        decision: .downgrade),
    Record(
        memberID: 12,
        avaNumOfFlight: 25,
        avaNumOfMilesOfFlight: 2741.6,
        numOfDays: 100,
        decision: .upgrade),
    Record(
        memberID: 13,
        avaNumOfFlight: 80,
        avaNumOfMilesOfFlight: 2401.2,
        numOfDays: 800,
        decision: .remain),
    Record(
        memberID: 14,
        avaNumOfFlight: 50,
        avaNumOfMilesOfFlight: 1929.7,
        numOfDays: 882,
        decision: .remain),
    Record(
        memberID: 15,
        avaNumOfFlight: 45,
        avaNumOfMilesOfFlight: 3370.0,
        numOfDays: 707,
        decision: .upgrade)
]

extension Double {
    var squared: Double {
        return self * self
    }
}


/// Run the kNN algorithm and return the nearest k neighbours.
///
/// - Parameters:
///   - k: the range
///   - r: the target record to classify
///   - givenRecords: dataset
/// - Returns: the nearest k neighbours
func runkNN(k: Int, newRecord r: Record, givenRecords: [Record], involveMiles: Bool = true) -> [Neighbour] {
    
    // 归一化：找出各个属性的最大最小值，然后归一化
    let minNumOfFlight = givenRecords.map({ $0.avaNumOfFlight }).min()!
    let maxNumOfFlight = givenRecords.map({ $0.avaNumOfFlight }).max()!
    let rangeNumOfFlight = Double(maxNumOfFlight - minNumOfFlight)
    // print("minNumOfFlight = \(minNumOfFlight), maxNumOfFlight = \(maxNumOfFlight), rangeNumOfFlight = \(rangeNumOfFlight)")
    
    let minNumOfMilesOfFlight = givenRecords.map({ $0.avaNumOfMilesOfFlight }).min()!
    let maxNumOfMilesOfFlight = givenRecords.map({ $0.avaNumOfMilesOfFlight }).max()!
    let rangeNumOfMilesOfFlight = maxNumOfMilesOfFlight - minNumOfMilesOfFlight
    
    let minNumOfDays = givenRecords.map({ $0.numOfDays }).min()!
    let maxNumOfDays = givenRecords.map({ $0.numOfDays }).max()!
    let rangeNumOfDays = Double(maxNumOfDays - minNumOfDays)
    
    // 计算欧式距离
    let distances: [(Int, Double)] = givenRecords.enumerated().map {
        let ai = Double($1.avaNumOfFlight - minNumOfFlight) / rangeNumOfFlight
        let aj = Double(r.avaNumOfFlight - minNumOfFlight) / rangeNumOfFlight
        let bi = ($1.avaNumOfMilesOfFlight - minNumOfMilesOfFlight) / rangeNumOfMilesOfFlight
        let bj = (r.avaNumOfMilesOfFlight - minNumOfMilesOfFlight) / rangeNumOfMilesOfFlight
        let ci = Double($1.numOfDays - minNumOfDays) / rangeNumOfDays
        let cj = Double(r.numOfDays - minNumOfDays) / rangeNumOfDays
        let distance = ((ai - aj).squared + (involveMiles ? (bi - bj).squared : 0) + (ci - cj).squared).squareRoot()
        return ($0, distance)
    }
    
    var neighbours = [Neighbour]()
    for (i, distance) in distances.sorted(by: { $0.1 < $1.1 }) {
        if neighbours.count >= k {
            break
        }
        neighbours.append((givenRecords[i], distance))
    }
    
    return neighbours
}

print("计算最邻近之5个邻居：")
let target2a = Record(memberID: -1, avaNumOfFlight: 25, avaNumOfMilesOfFlight: 2050.0, numOfDays: 790, decision: .tbd)
print("Target - \(target2a)")
runkNN(k: 5, newRecord: target2a, givenRecords: records).forEach {
    print("\($0.1) - \($0.0)")
}


print("\n尝试解答2b：")
let target2b = Record(memberID: -2, avaNumOfFlight: 58, avaNumOfMilesOfFlight: 0.0, numOfDays: 650, decision: .tbd)
print("Target - \(target2b)")
let result2b1 = runkNN(k: 5, newRecord: target2b, givenRecords: records, involveMiles: false)
result2b1.forEach {
    print("\($0.1) - \($0.0)")
}
let records2b1 = result2b1.map({ $0.0 }).sorted(by: { $0.avaTotalMiles < $1.avaTotalMiles })
records2b1.forEach {
    print("avaTotalMiles = \($0.avaTotalMiles) - \($0)")
}
let records2b2 = result2b1.map({ $0.0 }).sorted(by: { $0.actualTotalMiles < $1.actualTotalMiles })
records2b2.forEach {
    print("actualTotalMiles = \($0.actualTotalMiles) - \($0)")
}
