# RandomDistributionKit

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios_osx_tvos-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/phimage/RandomDistributionKit.svg?style=flat
           )](https://github.com/phimage/RandomDistributionKit/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/RandomDistributionKit.svg?style=flat)](http://cocoadocs.org/docsets/RandomDistributionKit/)

[<img align="left" src="logo.png" hspace="20">](#logo)  Add random distribution to random data generator framework [RandomKit](https://github.com/nvzqz/RandomKit)

```swift
var d: RandomDistribution = .exponential(rate: λ)
Double.random(distribution: d)

d = .gaussian(mean: 0, standardDeviation: 1)
let array: [Double] = Array(randomCount: 1000, distribution: d)

```

## Installation

## Using CocoaPods ##
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'RandomDistributionKit'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.


## Using Carthage ##
...
## Using SPM ##
...
