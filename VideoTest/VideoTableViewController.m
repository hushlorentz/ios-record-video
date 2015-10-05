//
//  VideoTableViewController.m
//  VideoTest
//
//  Created by Rich Halliday on 2015-09-15.
//  Copyright (c) 2015 Factor[e]. All rights reserved.
//

#import "VideoTableViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface VideoTableViewController ()

@end

@implementation VideoTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.videoList = [[NSMutableArray alloc] init];

  NSString *apiPath = @"http://26a5f145.ngrok.io/api/v1/";
  NSString *itemsIndexPath = [apiPath stringByAppendingString:@"items"];

  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

  void (^itemsIndexSuccess)(AFHTTPRequestOperation *operation, id responseObject) = ^void(AFHTTPRequestOperation *operation, id responseObject) {
    [self.videoList removeAllObjects];

    for (NSDictionary *item in responseObject[@"items"]) {
      Item *newItem = [[Item alloc] init];
      newItem.title = item[@"title"];
      newItem.video_url = item[@"video_url"];

      [self.videoList addObject:newItem];
      [self.tableView reloadData];
    }
  };

  void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^void(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"We failed with error: %@", error);
  };

  NSDictionary *params = @{};
  NSLog(@"Sending GET to %@", itemsIndexPath);
  [manager GET:itemsIndexPath parameters:params success:itemsIndexSuccess failure:failureBlock];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.videoList count];
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];

  cell.textLabel.text = ((Item *)self.videoList[[indexPath row]]).title;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.videoDelegate itemSelected:self.videoList[[indexPath row]]];
  [self dismissViewControllerAnimated:NO completion:nil];
}

@end
