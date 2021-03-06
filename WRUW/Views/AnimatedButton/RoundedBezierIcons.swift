//
//  RoundedBezierIcons.swift
//  PlayPauseButtonDemo
//
//  Created by Nick Jordan on 3/19/15.
//  Copyright (c) 2015 wruw. All rights reserved.
//

import UIKit

class RoundedBezierIcons: UIBezierPath {
    class RoundedSquareIcon: RoundedBezierIcons {
        init(frame: CGRect) {
            let floatPi = CGFloat.pi

            let rrect = CGRect(
                x: 0.125 * frame.size.width,
                y: 0.125 * frame.size.width,
                width: 0.75 * frame.size.width,
                height: 0.75 * frame.size.height
            )
            let radius = CGFloat(0.08 * frame.size.width)

            let minx = rrect.minX
            let maxx = rrect.maxX
            let miny = rrect.minY
            let maxy = rrect.maxY

            super.init()

            move(to: CGPoint(x: minx, y: maxy - radius))
            addArc(
                withCenter: CGPoint(x: minx + radius, y: miny + radius),
                radius: radius,
                startAngle: floatPi,
                endAngle: 3*floatPi/2,
                clockwise: true)
            addArc(
                withCenter: CGPoint(x: maxx - radius, y: miny + radius),
                radius: radius,
                startAngle: 3*floatPi/2,
                endAngle: 0,
                clockwise: true)
            addArc(
                withCenter: CGPoint(x: maxx - radius, y: maxy - radius),
                radius: radius,
                startAngle: 0,
                endAngle: floatPi/2,
                clockwise: true)
            addArc(
                withCenter: CGPoint(x: minx + radius, y: maxy - radius),
                radius: radius,
                startAngle: floatPi/2,
                endAngle: floatPi,
                clockwise: true)
            close()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class RoundedPlayIcon: RoundedBezierIcons {
        init(frame: CGRect) {
            let floatPi = CGFloat.pi

            let side = frame.size.width
            let radius = CGFloat(0.04 * side)
            let top = CGPoint(x: 0.25 * side, y: 0.85 * side)
            let bottom = CGPoint(x: 0.25 * side, y: 0.2 * side)
            let edge = CGPoint(x: 0.9 * side, y: 0.525 * side)

            let triLength = edge.x - bottom.x
            let triHeight = edge.y - bottom.y

            let tanArr = [CGFloat( atan(triLength / triHeight)), CGFloat( atan(triHeight) / triLength)]

            super.init()

            move(to: CGPoint(x: bottom.x, y: bottom.y + radius))
            addArc(
                withCenter: CGPoint(x: bottom.x + radius, y: bottom.y + radius),
                radius: radius,
                startAngle: floatPi,
                endAngle: -tanArr[0],
                clockwise: true)
            addArc(
                withCenter: CGPoint(x: edge.x - radius, y: edge.y),
                radius: radius,
                startAngle: -tanArr[0],
                endAngle: tanArr[0],
                clockwise: true)
            addArc(
                withCenter: CGPoint(x: top.x + radius, y: top.y - radius),
                radius: radius,
                startAngle: tanArr[0],
                endAngle: floatPi,
                clockwise: true)
            close()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
