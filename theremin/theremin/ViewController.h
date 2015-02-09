//
//  ViewController.h
//  theremin
//
//  Created by McCall Bliss on 2/1/15.
//  Copyright (c) 2015 tufts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "theremin-Swift.h"

@interface ViewController : UIViewController

// Sub-Classes
@property InstrumentViewController* instvc;

@property KnobViewController* knobvc;
@property NoteViewController* notevc;
@property GridViewController* gridvc;

@property NSString* key;

-(void) updateKey:(NSString *)key;

@end

