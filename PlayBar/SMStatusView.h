//
//  SMStatusView.h
//  PlayBar
//
//  Created by Stuart Moore on 8/12/12.
//
//

#import <Cocoa/Cocoa.h>

@interface SMStatusView : NSView <NSMenuDelegate>
{
    BOOL isMenuVisible;
}

@property (nonatomic, weak) NSStatusItem *statusItem;
@property (nonatomic, strong) NSPanel *popover;

@end
