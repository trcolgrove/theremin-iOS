//
//  CircleView.swift
//  theremin
//
//  Created by McCall Bliss, Thomas Colgrove, and Dan Defossez on 2/15/15.
//  Copyright (c) 2015 tufts. All rights reserved.
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
        
        // Set the circle outerline-colour and fill
        UIColor(white: 0.5, alpha: 0.3).setFill()
        UIColor(white: 0.5, alpha: 0.3).set()
        
        // Draw
        var rectangle = CGRectMake(0, 0, frame.width, frame.height)
        CGContextAddEllipseInRect(context, rectangle)
        CGContextFillEllipseInRect(context, rectangle)
        CGContextStrokePath(context);

    }
}