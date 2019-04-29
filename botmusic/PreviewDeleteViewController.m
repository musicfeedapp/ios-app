//
//  PreviewDeleteViewController.m
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "PreviewDeleteViewController.h"
#import "MFFeedTableCell.h"
#import "MGSwipeButton.h"

@interface PreviewDeleteViewController ()

@end

@implementation PreviewDeleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Tutorial track setter/getter

-(MFTrackItem*)tutorialTrack
{
    return [(PreviewViewController*)self.parentViewController.parentViewController tutorialTrack];
}
-(void)setTutorialTrack:(MFTrackItem*)track
{
    [(PreviewViewController*)self.parentViewController.parentViewController setTutorialTrack:track];
}

#pragma mark - TrackView Delegate methods

-(void)didLike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=[self tutorialTrack];
    [trackItem likeTrackItem];
    
    TrackView *trackView=[self trackViewForIndexPath:indexPath];
    [trackView setTrackInfo:trackItem];
}

-(void)didUnlike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=[self tutorialTrack];
    [trackItem dislikeTrackItem];
    
    TrackView *trackView=[self trackViewForIndexPath:indexPath];
    [trackView setTrackInfo:trackItem];}

#pragma mark - IBActions

-(IBAction)didSelectBeginDiscovery:(id)sender
{
    [playerManager stopTrack];
    [playerManager currentTrack].trackState = IRTrackItemStatePlayed;
    
    MFSideMenuContainerViewController *slidingVC = [MenuCreator createMenu:NO];
    
    [self presentViewController:slidingVC
                       animated:YES
                     completion:nil];
}

#pragma mark - Talbe View delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID= @"TrackCell";
    
    MFFeedTableCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell=[[MFFeedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.delegate = nil;
    
    //configure right buttons
    MGSwipeButton *swipeButtonRemove = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Remove",nil)
                                                      backgroundColor:[UIColor colorWithRGBHex:kAppMainColor]
                                                             callback:^BOOL(MGSwipeTableCell *sender) {
                                                                 return YES;
                                                             }];
    MGSwipeButton *swipeButtonMore = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"More",nil)
                                                    backgroundColor:[UIColor colorWithRGBHex:kAppPlayerColor]
                                                           callback:^BOOL(MGSwipeTableCell *sender) {
                                                               return YES;
                                                           }];
    
    cell.rightButtons =  @[swipeButtonRemove, swipeButtonMore];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    MGSwipeExpansionSettings* sws = [[MGSwipeExpansionSettings alloc] init];
    sws.buttonIndex = 0;
    sws.fillOnTrigger = YES;
    sws.threshold = 1;
    cell.rightExpansion = sws;
    
    [cell.trackView setTrackInfo:[self tutorialTrack]];
    [cell.trackView setDelegate:self];
    [cell.trackView setIndexPath:[indexPath copy]];
    [cell.trackView setTag:1];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TrackView trackViewHeight]+TRACK_VIEW_FOOTER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    TrackView *trackView=(TrackView*)[cell viewWithTag:1];
}

#pragma mark - Helpers

- (TrackView*)trackViewForIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    
    if(cell)
    {
        TrackView *trackView=(TrackView*)[cell.contentView viewWithTag:1];
        
        return trackView;
    }
    else
    {
        return nil;
    }
}

@end
