//
//  RoundedBezierIcons.swift
//  PlayPauseButtonDemo
//
//  Created by Nick Jordan on 3/19/15.
//  Copyright (c) 2015 wruw. All rights reserved.
//

import UIKit

class RoundedBezierIcons: UIBezierPath {
//    static let F_PI = CGFloat(M_PI)
    
    class func RoundedSquareIcon(frame: CGRect) -> UIBezierPath {
        let F_PI = CGFloat(M_PI)
        
        let rrect = CGRect(x: 0.125 * frame.size.width, y: 0.125 * frame.size.width, width: 0.75 * frame.size.width, height: 0.75 * frame.size.height)
        let radius = CGFloat(0.08 * frame.size.width)
        
        let minx = CGRectGetMinX(rrect)
        let maxx = CGRectGetMaxX(rrect)
        let miny = CGRectGetMinY(rrect)
        let maxy = CGRectGetMaxY(rrect)
        
        var bezier = UIBezierPath()
        
        bezier.moveToPoint(CGPoint(x: minx, y: maxy - radius))
        bezier.addArcWithCenter(
            CGPointMake(minx + radius, miny + radius),
            radius: radius,
            startAngle: F_PI,
            endAngle: 3*F_PI/2,
            clockwise: true)
        bezier.addArcWithCenter(
            CGPointMake(maxx - radius, miny + radius),
            radius: radius,
            startAngle: 3*F_PI/2,
            endAngle: 0,
            clockwise: true)
        bezier.addArcWithCenter(
            CGPointMake(maxx - radius, maxy - radius),
            radius: radius,
            startAngle: 0,
            endAngle: F_PI/2,
            clockwise: true)
        bezier.addArcWithCenter(
            CGPointMake(minx + radius, maxy - radius),
            radius: radius,
            startAngle: F_PI/2,
            endAngle: F_PI,
            clockwise: true)
        bezier.closePath()
        
        return bezier
    }
    
    class func RoundedPlayIcon(frame: CGRect) -> UIBezierPath {
        let F_PI = CGFloat(M_PI)
        
        let side = frame.size.width
        let radius = CGFloat(0.04 * side)
        let top = CGPointMake(0.25 * side, 0.85 * side)
        let bottom = CGPointMake(0.25 * side, 0.2 * side)
        let edge = CGPointMake(0.9 * side, 0.525 * side)
        
        let triLength = edge.x - bottom.x
        let triHeight = edge.y - bottom.y
        
        let tanArr = [CGFloat( atan(triLength / triHeight)), CGFloat( atan(triHeight) / triLength)]
        
        var bezier = UIBezierPath()
        bezier.moveToPoint(CGPointMake(bottom.x, bottom.y + radius))
        bezier.addArcWithCenter(
            CGPointMake(bottom.x + radius, bottom.y + radius),
            radius: radius,
            startAngle: F_PI,
            endAngle: -tanArr[0],
            clockwise: true)
        bezier.addArcWithCenter(
            CGPointMake(edge.x - radius, edge.y),
            radius: radius,
            startAngle: -tanArr[0],
            endAngle: tanArr[0],
            clockwise: true)
        bezier.addArcWithCenter(
            CGPointMake(top.x + radius, top.y - radius),
            radius: radius,
            startAngle: tanArr[0],
            endAngle: F_PI,
            clockwise: true)
        bezier.closePath()
        
        return bezier
    }
}
