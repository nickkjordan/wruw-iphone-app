//
//  RoundedBezierIcons.swift
//  PlayPauseButtonDemo
//
//  Created by Nick Jordan on 3/19/15.
//  Copyright (c) 2015 wruw. All rights reserved.
//

import UIKit

class RoundedBezierIcons: UIBezierPath {
    class func RoundedSquareIcon(_ frame: CGRect) -> UIBezierPath {
        let F_PI = CGFloat(M_PI)
        
        let rrect = CGRect(x: 0.125 * frame.size.width, y: 0.125 * frame.size.width, width: 0.75 * frame.size.width, height: 0.75 * frame.size.height)
        let radius = CGFloat(0.08 * frame.size.width)
        
        let minx = rrect.minX
        let maxx = rrect.maxX
        let miny = rrect.minY
        let maxy = rrect.maxY
        
        let bezier = UIBezierPath()
        
        bezier.move(to: CGPoint(x: minx, y: maxy - radius))
        bezier.addArc(
            withCenter: CGPoint(x: minx + radius, y: miny + radius),
            radius: radius,
            startAngle: F_PI,
            endAngle: 3*F_PI/2,
            clockwise: true)
        bezier.addArc(
            withCenter: CGPoint(x: maxx - radius, y: miny + radius),
            radius: radius,
            startAngle: 3*F_PI/2,
            endAngle: 0,
            clockwise: true)
        bezier.addArc(
            withCenter: CGPoint(x: maxx - radius, y: maxy - radius),
            radius: radius,
            startAngle: 0,
            endAngle: F_PI/2,
            clockwise: true)
        bezier.addArc(
            withCenter: CGPoint(x: minx + radius, y: maxy - radius),
            radius: radius,
            startAngle: F_PI/2,
            endAngle: F_PI,
            clockwise: true)
        bezier.close()
        
        return bezier
    }
    
    class func RoundedPlayIcon(_ frame: CGRect) -> UIBezierPath {
        let F_PI = CGFloat(M_PI)
        
        let side = frame.size.width
        let radius = CGFloat(0.04 * side)
        let top = CGPoint(x: 0.25 * side, y: 0.85 * side)
        let bottom = CGPoint(x: 0.25 * side, y: 0.2 * side)
        let edge = CGPoint(x: 0.9 * side, y: 0.525 * side)
        
        let triLength = edge.x - bottom.x
        let triHeight = edge.y - bottom.y
        
        let tanArr = [CGFloat( atan(triLength / triHeight)), CGFloat( atan(triHeight) / triLength)]
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: bottom.x, y: bottom.y + radius))
        bezier.addArc(
            withCenter: CGPoint(x: bottom.x + radius, y: bottom.y + radius),
            radius: radius,
            startAngle: F_PI,
            endAngle: -tanArr[0],
            clockwise: true)
        bezier.addArc(
            withCenter: CGPoint(x: edge.x - radius, y: edge.y),
            radius: radius,
            startAngle: -tanArr[0],
            endAngle: tanArr[0],
            clockwise: true)
        bezier.addArc(
            withCenter: CGPoint(x: top.x + radius, y: top.y - radius),
            radius: radius,
            startAngle: tanArr[0],
            endAngle: F_PI,
            clockwise: true)
        bezier.close()
        
        return bezier
    }
}
