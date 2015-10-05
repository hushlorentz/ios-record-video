//
//  ViewController.h
//  VideoTest
//
//  Created by Rich Halliday on 2015-09-14.
//  Copyright (c) 2015 Factor[e]. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"
#import <UIKit/UIKit.h>
#import "VideoTableViewController.h"
@import MediaPlayer;

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, VideoTableSelection>

@property (nonatomic, weak) UIButton IBOutlet *videoButton;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) AVURLAsset *videoAsset;
@property (nonatomic) MPMoviePlayerController *mpMoviePlayer;

@end
