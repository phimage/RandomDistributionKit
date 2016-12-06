//
//  DiscreteRandomDistribution.swift
//  RandomDistributionKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016-2017 Eric Marchand
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
    import Darwin
#elseif os(Linux)
    import Glibc
#endif
import RandomKit

// Protocol to generate a random probability
public protocol BernoulliProbability: RandomWithinClosedRange, ExpressibleByIntegerLiteral, Comparable {
    
    // Range of value used for bernouilli probability (usually 0...1).
    static var bernouilliRange: ClosedRange<Self> {get}
    
    // some utility operators and functions for poisson distribution
    static prefix func -(lhs: Self) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    func exp() -> Self
    
}

extension BernoulliProbability {
    
    // Generate a random value within the `bernouilliRange` comparable to the probability parameters of the distribution.
    public static func randomProbability(using randomGenerator: RandomGenerator = .default) -> Self {
        return Self.random(within: Self.bernouilliRange, using: randomGenerator)
    }
    
}


// Type of random discrete random distribution.
// https://en.wikipedia.org/wiki/Probability_distribution#Discrete_probability_distribution
public enum DiscreteRandomDistribution<T: DiscreteRandomDistribuable, P: BernoulliProbability> {
    
    // https://en.wikipedia.org/wiki/Bernoulli_distribution
    case bernoulli(probability: P)
    // https://en.wikipedia.org/wiki/Binomial_distribution
    case binomial(trials: Int, probability: P)
    // https://en.wikipedia.org/wiki/Geometric_distribution
    case geometric(probability: P)
    // https://en.wikipedia.org/wiki/Poisson_distribution
    case poisson(frequency: P)
    // https://en.wikipedia.org/wiki/Discrete_uniform_distribution
    case uniform(min: T, max: T)
}

/// A type that can generate a random value using specified `DiscreteRandomDistribution`
public protocol DiscreteRandomDistribuable: Random, RandomWithinClosedRange, ExpressibleByIntegerLiteral, Equatable {
    // The two possible values.
    static var bernoulliValues: (Self, Self) {get}
    
    // Maths Operators (like IntegerArithmetic)
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    
}

extension DiscreteRandomDistribuable {
    
    // Generate a random value from specified distribution.
    public static func random<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> Self {
        switch(distribution) {
        case .bernoulli(let p):
            return randomBernoulli(probability: p, using: randomGenerator)
        case .binomial(let n, let p):
            return randomBinomial(trials:n, probability: p, using: randomGenerator)
        case .geometric(let p):
            return randomGeometric(probability: p, using: randomGenerator)
        case .poisson(let λ):
            return randomPoisson(frequency: λ, using: randomGenerator)
        case .uniform(let min, let max):
            return random(within: min...max, using: randomGenerator)
        }
    }
    
    // Generate a random value from bernouilli distribution.
    // https://en.wikipedia.org/wiki/Bernoulli_distribution
    // - parameter probability: probability p parameter of bernouilli distribution. Must be > 0 and <1.
    public static func randomBernoulli<P: BernoulliProbability>(probability p: P, using randomGenerator: RandomGenerator = .default)  -> Self {
        let b = Self.bernoulliValues
        
        let x = P.randomProbability(using: randomGenerator)
        return x < p ? b.1 : b.0
    }
    
    // Generate a random value from binomial distribution.
    // https://en.wikipedia.org/wiki/Binomial_distribution
    // - parameter trials: trials parameter of binomial distribution.
    // - parameter probability: probability p parameter of binomial distribution. Must be > 0 and <1.
    public static func randomBinomial<P: BernoulliProbability>(trials n: Int, probability p: P, using randomGenerator: RandomGenerator = .default) -> Self {
        let y: [Self] = (0..<n).map({ _ in randomBernoulli(probability: p, using: randomGenerator) })
        return y.reduce(0, +)
    }
    
    // Generate a random value from geometric distribution.
    // https://en.wikipedia.org/wiki/Geometric_distribution
    // - parameter probability: probability p parameter of geometric distribution. Must be > 0 and <1.
    public static func randomGeometric<P: BernoulliProbability>(probability p: P, using randomGenerator: RandomGenerator = .default) -> Self {
        let b = Self.bernoulliValues
        var x = b.0
        while randomBernoulli(probability: p, using: randomGenerator) != b.1 {
            x = x + b.1
        }
        return x
    }
    
    // Generate a random value from poisson distribution.
    // https://en.wikipedia.org/wiki/Poisson_distribution
    // - parameter frequency: λ parameter of poisson distribution. Must be > 0 and exp(-λ)!= 0.
    public static func randomPoisson<P: BernoulliProbability>(frequency λ: P, using randomGenerator: RandomGenerator = .default) -> Self {
        var x: Self = 0
        var xD: P = 0
        let one: P = 1
        var p = (-λ).exp()
        // precondition(p != 0)
        var s = p
        let u = P.randomProbability(using: randomGenerator)
        while u > s {
            x = x + 1
            xD = xD + one
            p = p * (λ / xD)
            s = s + p
        }
        return x
    }
    
}

// MARK: - Iterator & Sequence
extension DiscreteRandomDistribuable {
    
    /// Returns a generator for random values using `distribution`.
    public static func randomIterator<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        return AnyIterator { random(distribution: distribution, using: randomGenerator) }
    }
    
    /// Returns a generator for random values using `distribution` within `maxCount`.
    public static func randomIterator<P: BernoulliProbability>(maxCount count: Int, distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnyIterator<Self> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }
            return n < count ? random(distribution: distribution, using: randomGenerator) : nil
        }
    }
    
    /// Returns a sequence of infinite random values using specified distribution.
    public static func randomSequence<P: BernoulliProbability>(distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(distribution: distribution, using: randomGenerator))
    }
    
    /// Returns a sequence of random values using specified distribution within `maxCount`.
    public static func randomSequence<P: BernoulliProbability>(maxCount count: Int, distribution: DiscreteRandomDistribution<Self, P>, using randomGenerator: RandomGenerator = .default) -> AnySequence<Self> {
        return AnySequence(randomIterator(maxCount: count, distribution: distribution, using: randomGenerator))
    }
    
}
