//
//  CircleView.swift
//  IOS8SwiftDrawingCirclesTutorial
//
//  Created by Arthur Knopper on 12/10/14.
//  Copyright (c) 2014 Arthur Knopper. All rights reserved.
//

import UIKit

class CircleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(rect: CGRect) {
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext();
        
        // Set the circle outerline-width
        CGContextSetLineWidth(context, 5.0);
        
        // Set the circle outerline-colour
        UIColor(white: 0.5, alpha: 0.3).setFill()
        UIColor(white: 0.5, alpha: 0.3).set()
        
        var rectangle = CGRectMake(0, 0, frame.width, frame.height)
        CGContextAddEllipseInRect(context, rectangle)
        CGContextFillEllipseInRect(context, rectangle)
        CGContextStrokePath(context);

        // Create Circle
        //CGContextAddArc(context, (frame.size.width)/2, frame.size.height/2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
        // Draw
        //CGContextStrokePath(context)
        //CGContextFillPath(context)
    }
}