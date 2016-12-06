//
//  RandomDistributionKitTests.swift
//  RandomDistributionKitTests
//
//  Created by phimage on 06/12/16.
//  Copyright © 2016 phimage. All rights reserved.
//

import XCTest
@testable import RandomDistributionKit
import RandomKit

class RandomDistributionKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testRandomGaussian() {
        let count = 10000
        let mean: Double = 0
        let standardDeviation: Double = 1
        let distribution: RandomDistribution = .gaussian(mean: mean, standardDeviation: standardDeviation)
        let array: [Double] = Array(randomCount: count, distribution: distribution)
        
        XCTAssertEqual(array.count, count)
        
        var sum: Double = 0
        for e in array {
            sum += e
        }
        let theMean = sum / Double(count)
        XCTAssertEqualWithAccuracy(mean, theMean, accuracy: 0.1)
        
        let m = DistributionMoment(data: array)
        let k = m.excessKurtosis
        let s = m.skewness
        
        XCTAssertEqualWithAccuracy(m.mean, theMean, accuracy: 0.00001)
        
        // Check if could be a gauss/ normal distribution
        XCTAssertEqual(round(k), 0, "\(k)")
        XCTAssertEqual(round(s), 0, "\(s)")
        
    }
    
    func testRandomExponential() {
        let count = 10000
        let λ = Double.random(within: DBL_MIN...DBL_MAX)
        
        let distribution: RandomDistribution = .exponential(rate: λ)
        let array: [Double] = Array(randomCount: count, distribution: distribution)
        XCTAssertEqual(array.count, count)
        
        let m = DistributionMoment(data: array)
        XCTAssertEqualWithAccuracy(m.mean, 1.0 / λ, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(m.variance, 1.0 / (λ * λ), accuracy: 0.01)
    }
    
    func testRandomWeibull() {
        let count = 1000000
        let scale = Double.random(within: DBL_MIN...10000000)
        let shape = Double.random(within: DBL_MIN...10000000)
        
        let distribution: RandomDistribution = .weibull(scale: scale, shape: shape)
        let array: [Double] = Array(randomCount: count, distribution: distribution)
        XCTAssertEqual(array.count, count)
        
        // let m = DistributionMoment(data: array)
    }
    
    func testRandomBernoulli() {
        let p = Double.random()
        let count = 10000
        let distribution: DiscreteRandomDistribution<Int, Double> = .bernoulli(probability: p)
        let array: [Int] = Array(randomCount: count, distribution: distribution)
        
        for e in array {
            XCTAssert(0 == e || e == 1)
        }
        XCTAssertEqual(array.count, count)
        
        let (mean, variance) = discretMoment(array)
        XCTAssertEqualWithAccuracy(mean, p, accuracy: discretAccuracy)
        XCTAssertEqualWithAccuracy(variance, p * (1 - p), accuracy: discretAccuracy)
    }
    
    func testRandomBinomial() {
        let count = 10000
        let trials = Int.random(within:1...1000)
        let p = Double.random(within:0...1)
        let distribution: DiscreteRandomDistribution<Int, Double> = .binomial(trials: trials, probability: p)
        let array: [Int] = Array(randomCount: count, distribution: distribution)
        
        XCTAssertEqual(array.count, count)
        
        let (mean, variance) = discretMoment(array)
        XCTAssertEqualWithAccuracy(mean, Double(trials) * p, accuracy: Double(trials) * discretAccuracy)
        XCTAssertEqualWithAccuracy(variance, Double(trials) * p * (1 - p), accuracy: Double(trials) * discretAccuracy)
    }
    
    func testRandomGeometric() {
        let count = 10000
        let p = Double.random(within: 0...1)
        
        let distribution: DiscreteRandomDistribution<Int, Double> = .geometric(probability: p)
        let array: [Int] = Array(randomCount: count, distribution: distribution)
        
        XCTAssertEqual(array.count, count)
        
        let (mean, variance) = discretMoment(array)
        XCTAssertEqualWithAccuracy(mean, (1 - p) / p, accuracy: 1)
        XCTAssertEqualWithAccuracy(variance, (1 - p) / (p * p), accuracy: 1)
    }
    
    func testRandomPoisson() {
        let count = 10000
        let λ = Double.random(within: DBL_MIN...500)
        
        let distribution: DiscreteRandomDistribution<Int, Double> = .poisson(frequency: λ)
        let array: [Int] = Array(randomCount: count, distribution: distribution)
        XCTAssertEqual(array.count, count)
        
        let (mean, variance) = discretMoment(array)
        XCTAssertEqualWithAccuracy(mean, λ, accuracy: discretAccuracy * Double(count))
        XCTAssertEqualWithAccuracy(variance, λ, accuracy: discretAccuracy * Double(count))
    }
    
    // MARK: utils
    
    private static func randomDictionaryOfCount(_ count: Int) -> [Int : Int] {
        return (0 ..< count).reduce(Dictionary(minimumCapacity: count)) { (dict, num) in
            var mutableDict = dict
            
            mutableDict[num] = num
            return mutableDict
        }
    }
    
    private func roundToPlaces(_ value: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    private func round10(_ value: Double) -> Double {
        return roundToPlaces(value, places: 10)
    }
    
    private func discretMoment(_ array: [Int]) -> (mean: Double, variance: Double) {
        let dCount = Double(array.count)
        let mean = Double(array.reduce(0, +)) / dCount
        let varianceSum = { (current: Double, val: Int) in
            current + (Double(val) - mean) * (Double(val) - mean)
        }
        let variance = array.reduce(0.0, varianceSum) / dCount
        
        return (mean: mean, variance: variance)
    }
    
    var discretAccuracy = 0.007
    
}
