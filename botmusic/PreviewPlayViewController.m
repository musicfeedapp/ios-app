//
//  PreviewPlayViewController.m
//  botmusic
//
//  Created by Supervisor on 06.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "PreviewPlayViewController.h"

@interface PreviewPlayViewController ()

@property(nonatomic,weak)IBOutlet UIView *playerContainer;

@property(nonatomic,strong)TrackView *trackView;

@end

@implementation PreviewPlayViewController

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
    
    [self createTrackView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_trackView setTrackInfo:[self tutorialTrack]];
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

#pragma mark - Create track view

-(void)createTrackView
{
    _trackView=[TrackViewCreator createTrackView];
    
    [_trackView.separatorView setHidden:YES];
    [_trackView setTapEnable:YES];
    [_trackView setDelegate:self];
    
    [_trackView setFrame:CGRectMake(0, 125, self.view.frame.size.width, 225)];
    
    [self.view addSubview:_trackView];
}

#pragma mark - TrackView Delegate methods

-(void)didTapOnView:(TrackView*)trackView;
{
    if(playerManager.haveTrack){
        
        if(playerManager.playing){
            [playerManager pauseTrack];
        }else{
            [playerManager resumeTrack];
        }
    }else{
        MFTrackItem *trackItem=[self tutorialTrack];
        
        if(trackItem)
        {
//            playerManager.delegateVC=self;
//            [playerManager playTracks:@[trackItem] trackIndex:0];
        }
    }
}
-(void)didLike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=[self tutorialTrack];
    [trackItem likeTrackItem];
    
    [_trackView setTrackInfo:trackItem];
    [self setTutorialTrack:trackItem];
}
-(void)didUnlike:(NSIndexPath *)indexPath
{
    MFTrackItem *trackItem=[self tutorialTrack];
    [trackItem dislikeTrackItem];
    
    [_trackView setTrackInfo:trackItem];
    [self setTutorialTrack:trackItem];
}

#pragma mark - PlayerViewControllerDelegate
- (void)startPlayingTrack:(MFTrackItem*)trackItem{}
- (void)pauseTrack{}
- (void)resumeTrack{}
- (void)stopTrack{}
- (void)updateProgress:(CGFloat)seconds{}
- (void)playbackAvailable:(BOOL)available{
    if(available){
//        [self.trackView.activityView startAnimating];
    }else{
//        [self.trackView.activityView stopAnimating];
    }
}
- (void)loadingFinished{
//    [self.trackView.activityView stopAnimating];
}

@end
