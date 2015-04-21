//
//  PlayButton.swift
//  theremin
//
//  Created by Daniel Defossez on 4/6/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class PlayButton : UIButton {
    
    override func drawRect(rect: CGRect) {
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext();
        
        // Set the triangle outerline-width
        CGContextSetLineWidth(context, 5.0);
        
        // Set the circle outerline-colur and fill
        UIColor(red: 51/255.0, green: 51.0/255, blue: 51.0/255, alpha: 1.0).setFill()
        UIColor(red: 244.0/255.0, green: 59.0/255, blue: 59.0/255, alpha: 1.0).set()
        
        // Draw
        var rectangle = CGRectMake(0, 0, frame.width, frame.height)
        CGContextFillEllipseInRect(context, rectangle)
        CGContextStrokePath(context);
        
    }
    
    
}