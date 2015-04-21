//
//  GridLineView.swift
//  theremin
//
//  Created by Thomas Colgrove on 3/3/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

import Foundation
import UIKit

class GridLineView: UIView {
    var index = 0
    var gvc: GridViewController
    
    init(frame: CGRect, view_controller: GridViewController) {
        gvc = view_controller
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(rect: CGRect) {
        // Get the Graphics Context
        var context = UIGraphicsGetCurrentContext();
        
        // Set the rect outerline-width
        CGContextSetLineWidth(context, 5.0);
        
        // Set the rekt outerline-colour and fill
        //UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).setFill()
        UIColor(white: 0.5, alpha: 0.5).set()
        
        // Draw
        var rectangle = CGRectMake(0, 0, frame.width, frame.height)
        CGContextStrokeRect(context, rectangle)
        CGContextStrokePath(context)
        CGContextFillRect(context, rectangle)
        
    }
    
}