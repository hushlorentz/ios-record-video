//
//  VideoTableViewController.h
//  VideoTest
//
//  Created by Rich Halliday on 2015-09-15.
//  Copyright (c) 2015 Factor[e]. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@protocol VideoTableSelection
- (void)itemSelected:(Item *)selectedItem;
@end

@interface VideoTableViewController : UITableViewController

@property NSMutableArray *videoList;
@property id <VideoTableSelection> videoDelegate;

@end
