# Pedestrian Status
Pedestrian Status is a step detection app written with Swift. It does so by analysing the acceleration of it’s user while he/she is holding his/her iPhone.

![](http://www.cansurmeli.com/other/github/pedestrian-status/pedestrian-status-app-screenshot.jpg)

## Description

Pedestrian Status uses the step detection algorithm acquired from [this research](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=5507251)([PDF via RG](https://www.researchgate.net/publication/224154935_Accelerometer_Assisted_Robust_Wireless_Signal_Positioning_Based_on_a_Hidden_Markov_Model)).

The above researches algorithm provides three statuses: static, slow walking or fast walking. If it’s a slow walking pattern, the step count will be incremented by 1. If it’s fast walking, then it will be incremented by 2.

It’s known that Pedestrian status is not without it’s flaws. Currently, the iPhone running Pedestrian Status should be hold at the waistline level and parallel to the floor. Like below:

![](http://www.cansurmeli.com/other/github/pedestrian-status/pedestrian-status-required-walking-style.jpg)

Also sharply moving the hand will result in additionally detected steps as it will be detected as acceleration enough to be classified as a step.

Pedestrian Status is a proof-of-concept. Therefore such shortcomings as explained above are present. In a future version, it will probably be much more agile.

## Usage
Just download the project and run it on an iPhone.

An iPad will also work but it’s more appropriate to move with an iPhone.

## Requirements
- Xcode 7.0 or higher
- Swift 2.0
- ARC

## Future Work
- recording sensor data
- dynamic acceleration threshold calculation
- recognising unnecessary hand movements
