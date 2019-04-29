//
//  PreviewDeleteViewController.h
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuCreator.h"
#import "TrackView.h"
#import "TrackViewCreator.h"
#import "PreviewViewController.h"

@interface PreviewDeleteViewController : UIViewController <TrackViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic) TrackView *trackView;

-(IBAction)didSelectBeginDiscovery:(id)sender;

@end
