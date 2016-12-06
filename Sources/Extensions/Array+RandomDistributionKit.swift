//
//  Array+RandomDistributionKit.swift
//  RandomDistributionKit
//
//  Created by phimage on 06/12/16.
//  Copyright © 2016 phimage. All rights reserved.
//

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif
import RandomKit

// MARK: RandomDistribuable
extension Array where Element: RandomDistribuable {
    
    /// Construct an Array of random elements using `distribution`.
    public init(randomCount: Int, distribution: RandomDistribution<Element>, using randomGenerator: RandomGenerator = .default) {
        self = Array(Element.randomSequence(maxCount: randomCount, distribution: distribution, using: randomGenerator))
    }
    
}

// MARK: DiscreteRandomDistribuable
extension Array where Element: DiscreteRandomDistribuable {
    
    /// Construct an Array of random elements using `distribution`.
    public init<P: BernoulliProbability>(randomCount: Int, distribution: DiscreteRandomDistribution<Element, P>, using randomGenerator: RandomGenerator = .default) {
        self = Array(Element.randomSequence(maxCount: randomCount, distribution: distribution, using: randomGenerator))
    }
    
}
