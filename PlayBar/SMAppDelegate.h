//
//  SMAppDelegate.h
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SMAppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *myStatusItem;
    IBOutlet NSMenu *myStatusMenu;
}

@property (strong, nonatomic) IBOutlet NSPanel *popover;

@end
