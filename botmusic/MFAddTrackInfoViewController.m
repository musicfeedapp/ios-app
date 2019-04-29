//
//  MFAddTrackInfoViewController.m
//  botmusic
//

#import "MFAddTrackInfoViewController.h"
#import "UIImageView+WebCache_FadeIn.h"
#import "NDMusicControl.h"
#import "MFNotificationManager.h"
#import <UIColor+Expanded.h>

static NSString * const kTrackStateKeyPath = @"trackItem.trackState";

@interface MFAddTrackInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *likesNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *addTrackButton;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repostIconLabel;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;

@end

@implementation MFAddTrackInfoViewController{
    BOOL gradientSetUp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateTrackInfo];
    [self addObserver:self forKeyPath:kTrackStateKeyPath
              options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
              context:nil];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!gradientSetUp) {
        gradientSetUp = YES;
        CAGradientLayer* gradient = [CAGradientLayer layer];
        CGFloat gragientHeight = self.artworkImageView.frame.size.height*2.0/3.0;
        gradient.frame = CGRectMake(0, 0, self.artworkImageView.frame.size.width, gragientHeight);
        UIColor *startColour = [UIColor colorWithWhite:0 alpha:0.7];
        UIColor *endColour = [UIColor colorWithWhite:0 alpha:0.0];
        gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
        [self.artworkImageView.layer addSublayer:gradient];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateTrackInfo{
    self.likesNumberLabel.text = [NSString stringWithFormat:@"%@", self.trackItem.likes];
    [self.artworkImageView sd_setImageAndFadeOutWithURL:[NSURL URLWithString:self.trackItem.trackPicture] placeholderImage:[UIImage imageNamed:@"DefaultArtwork"]];
    self.trackNameLabel.text = self.trackItem.trackName;
    if (self.trackItem.isLiked) {
        [self showLike];
    } else {
        [self showUnlike];
    }
    [self trackStateChanged:self.trackItem.trackState];
    if (self.trackItem.isNotPosted) {

        self.repostIconLabel.text = @"";
        [self.repostButton setTitle:@"Post" forState:UIControlStateNormal];
        self.repostButton.backgroundColor = [UIColor colorWithRGBHex:0x00CC77];

    } else {

        self.repostIconLabel.text = @"";
        [self.repostButton setTitle:@"Repost" forState:UIControlStateNormal];
        self.repostButton.backgroundColor = [UIColor colorWithRGBHex:0x3284FF];

    }
}
- (void) setTrackItem:(MFTrackItem *)trackItem{
    _trackItem = trackItem;
    [self updateTrackInfo];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)addTrackButtonTapped:(id)sender {
    [self.delegate didSelectAddTrack:self.trackItem];
}

- (IBAction)shareButtonTapped:(id)sender {
    [self.delegate didSelectShareTrack:self.trackItem];
}

- (IBAction)repostButtonTapped:(id)sender {
    [[IRNetworkClient sharedInstance] publishTrackByID:self.trackItem.itemId SuccessBlock:^(NSDictionary *dictionary) {
        [[MFMessageManager sharedInstance] showTrackRepostedMessageInViewController:[(UIViewController*)self.delegate tabBarController]];

    } failureBlock:^(NSString *errorMessage) {
        [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:[(UIViewController*)self.delegate tabBarController]];

    }];
}

- (IBAction)likeButtonTapped:(id)sender {
    if (!self.trackItem.isLiked) {
        [self didLikeTrack:self.trackItem];
    } else {
        [self didUnlikeTrack:self.trackItem];
    }
}

- (void)didLikeTrack:(MFTrackItem *)track
{


    [[IRNetworkClient sharedInstance]likeTrackById:self.trackItem.itemId
                                         withEmail:userManager.userInfo.email
                                             token:[userManager fbToken]
                                      successBlock:^{
                                          [self.trackItem likeTrackItem];

                                          NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.trackItem
                                                                                               forKey:@"trackItem"];
                                          [[NSNotificationCenter defaultCenter] postNotificationName:PlayerLikeNotificationEvent
                                                                                              object:self
                                                                                            userInfo:userInfo];
                                          [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                          [MFNotificationManager postTrackLikedNotification:track];
                                      }
                                      failureBlock:^(NSString *errorMessage){
                                          [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:[(UIViewController*)self.delegate tabBarController]];
                                          [self showUnlike];
                                      }];
    [self showLike];
}

- (void)didUnlikeTrack:(MFTrackItem *)track
{



    [[IRNetworkClient sharedInstance]unlikeTrackById:self.trackItem.itemId
                                           withEmail:userManager.userInfo.email
                                               token:[userManager fbToken]
                                        successBlock:^{
                                            [self.trackItem dislikeTrackItem];

                                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.trackItem
                                                                                                 forKey:@"trackItem"];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:PlayerUnlikeNotificationEvent
                                                                                                object:self
                                                                                              userInfo:userInfo];
                                            [MFNotificationManager postUpdateLovedTracksPlaylistNotification];
                                            [MFNotificationManager postTrackDislikedNotification:track];

                                        }
                                        failureBlock:^(NSString *errorMessage){
                                            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:[(UIViewController*)self.delegate tabBarController]];
                                            [self showLike];
                                        }];
    
    [self showUnlike];
}

- (void)showLike{
    self.likeLabel.text = @"";
}

- (void)showUnlike{
    self.likeLabel.text = @"";
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    id newObject = [change objectForKey:NSKeyValueChangeNewKey];
    
    if ([NSNull null] == (NSNull*)newObject)
        newObject = nil;
    
    if ([kTrackStateKeyPath isEqualToString:keyPath]) {
        [self trackStateChanged:[newObject integerValue]];
    }
}

- (void)trackStateChanged:(NDMusicConrolStateType)state {
    switch (state) {
        case NDMusicConrolStateTypeNotStarted:
            self.pauseButton.hidden = YES;
            self.playButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypeLoading:
            self.pauseButton.hidden = YES;
            self.playButton.hidden = YES;
            [self.activityIndicator startAnimating];
            break;
        case NDMusicConrolStateTypeFailed:
            self.pauseButton.hidden = YES;
            self.playButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePaused:
            self.pauseButton.hidden = YES;
            self.playButton.hidden = NO;
            [self.activityIndicator stopAnimating];
            break;
        case NDMusicConrolStateTypePlaying:
            self.pauseButton.hidden = NO;
            self.playButton.hidden = YES;
            [self.activityIndicator stopAnimating];
            
            break;
        default:
            break;
    }
}

- (IBAction)trackTapped:(id)sender {
    if (![playerManager.currentTrack isEqual:self.trackItem]) {
        [playerManager playSingleTrack:self.trackItem];
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    [self removeObserver:self
              forKeyPath:kTrackStateKeyPath
                 context:nil];
}

@end
