//
//  ViewController.m
//  VideoTest
//
//  Created by Rich Halliday on 2015-09-14.
//  Copyright (c) 2015 Factor[e]. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClick {
  NSLog(@"We click!");
  UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
  //cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
  
  cameraUI.mediaTypes = @[(NSString*)kUTTypeMovie];
  cameraUI.allowsEditing = NO;
  cameraUI.videoQuality = UIImagePickerControllerQualityTypeLow;
  cameraUI.videoMaximumDuration = 10;
  
  cameraUI.delegate = self;
  
  [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  //NSLog(@"We picked! %@", info);
  NSURL *fileURL = info[@"UIImagePickerControllerMediaURL"];
  if (fileURL) {
    NSLog(@"We have path from url: %@", [fileURL path]);
  } else {
    NSLog(@"We have no url");
  }

  [self playVideo:fileURL];

  NSError *error;
  NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:&error];
  NSLog(@"Size of movie: %llu", [fileAttributes fileSize]);

  [self dismissViewControllerAnimated:YES completion:nil];

  NSString *apiPath = @"http://26a5f145.ngrok.io/api/v1/";
  NSString *itemsIndexPath = [apiPath stringByAppendingString:@"items"];

  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  
  void (^itemsIndexSuccess)(AFHTTPRequestOperation *operation, id responseObject) = ^void(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"We did it: %@", responseObject);
  };

  void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^void(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"We failed with error: %@", error);
  };

  //NSDictionary *params = @{};
  //NSLog(@"Sending GET to %@", itemsIndexPath);
  //[manager GET:itemsIndexPath parameters:params success:itemsIndexSuccess failure:failureBlock];

  NSData *videoData = [NSData dataWithContentsOfURL:fileURL];
  NSDictionary *params = @{ @"item" : @{ } };
  NSLog(@"Sending POST to %@", itemsIndexPath);

  void (^formDataBlock)(id <AFMultipartFormData> formData) =  ^(id <AFMultipartFormData> formData) { 
      [formData appendPartWithFileData: videoData name:@"item[video]" fileName:@"test.mov" mimeType:@"video/quicktime"];
      //[formData appendPartWithFormData:videoData name:@"video"];
     
  };
  //[manager POST:itemsIndexPath parameters:params success:itemsIndexSuccess failure:failureBlock];
  //[manager POST:itemsIndexPath parameters:params constructingBodyWithBlock:formDataBlock success:itemsIndexSuccess failure:failureBlock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)itemSelected:(Item *)selectedItem {
  NSLog(@"View controller says we selected: %@", selectedItem.title);

  NSURL *videoURL = [NSURL URLWithString:[@"http://26a5f145.ngrok.io" stringByAppendingString:selectedItem.video_url]];
  //NSURL *videoURL = [NSURL URLWithString:@"http://26a5f145.ngrok.io/api/v1/items/first_video"];

  //[self playVideo:videoURL];
  [self playVideoNew:videoURL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  VideoTableViewController *vidController = (VideoTableViewController *)[segue destinationViewController];
  vidController.videoDelegate = self;
}

- (void)playVideoNew:(NSURL *)url {
  NSLog(@"Trying to play %@ with MPMoviePlayer", url);
  self.mpMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
  [self.mpMoviePlayer prepareToPlay];
  [self.mpMoviePlayer.view setFrame: self.view.bounds];  // player's frame must match parent's
  [self.view addSubview: self.mpMoviePlayer.view];
  [self.mpMoviePlayer play];
}

- (void)playVideo:(NSURL *)url {
  NSLog(@"Trying to play %@ with AVPlayer", url);
  self.videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
  self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.videoAsset];
  self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];

  AVPlayerLayer *layer = [AVPlayerLayer layer];

  [layer setPlayer:self.player];
  [layer setFrame:CGRectMake(10, 10, 300, 200)];
  [layer setBackgroundColor:[UIColor redColor].CGColor];
  [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

  [self.view.layer addSublayer:layer];
  [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self.player && [keyPath isEqualToString:@"status"]) {
    if (self.player.status == AVPlayerStatusReadyToPlay) {
      NSLog(@"We are ready to go!");
      [self.player play];
    } else if (self.player.status == AVPlayerStatusFailed) {
      NSLog(@"Error on playback: %@", self.player.error);
    }
  }
}

@end
