//
//  MFAddTrackViewController.m
//  botmusic
//

#import "MFAddTrackViewController.h"
#import "UIColor+Expanded.h"
#import "MFRecognitionManager.h"
#import "PlaylistTrackCell.h"
#import "MFAddTrackInfoViewController.h"
#import "PlaylistsViewController.h"
#import "PlaylistTracksViewController.h"
#import "MagicalRecord/MagicalRecord.h"

@interface MFAddTrackViewController () <MFRecognitionManagerDelegate, PlaylistTrackCellDelegate, MFAddTrackInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UIButton *searchAddButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vizHeight;
@property (weak, nonatomic) IBOutlet UIView *addTrackView;

//link view
@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet UITextField *linkField;
@property (weak, nonatomic) IBOutlet UIButton *cancelLinkButton;

//identify view
@property (weak, nonatomic) IBOutlet UIView *identifyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoSize;
@property (weak, nonatomic) IBOutlet UIView *pageViewControllerContainer;
@property (strong, nonatomic) MFAddTrackInfoViewController* trackResultViewController;
@property (weak, nonatomic) IBOutlet UIView *vuView;
@property (weak, nonatomic) IBOutlet UILabel *identifyingLabel;
@property (weak, nonatomic) IBOutlet UILabel *identifiedLabel;
@property (weak, nonatomic) IBOutlet UIButton *listenAgainButton;
@property (weak, nonatomic) IBOutlet UILabel *noResultsFoundLabel;

//searchView
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (nonatomic, strong) NSArray* searchResults;

@property (nonatomic, strong) MFPlaylistItem* historyPlaylist;
@property (nonatomic) BOOL buttonsSetUp;
@end

@implementation MFAddTrackViewController{
    
    float _lastLevel1;
    float _lastLevel2;
    float _lastLevel3;
    float _lastLevel4;
    float _lastLevel5;
    float _averageLevel;
    int _averageCount;
    float _averageLogoHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *color = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    NSMutableAttributedString* attrString = [self.linkField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.linkField.attributedPlaceholder = attrString;
    
    attrString = [self.searchField.attributedPlaceholder mutableCopy];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){0,attrString.length}];
    self.searchField.attributedPlaceholder = attrString;

    self.trackResultViewController = [[MFAddTrackInfoViewController alloc] init];
    self.trackResultViewController.trackItem = nil;
    self.trackResultViewController.delegate = self;
    
    [self addChildViewController:self.trackResultViewController];
    self.trackResultViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.pageViewControllerContainer addSubview:self.trackResultViewController.view];

    [self.pageViewControllerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:@{@"view" : self.trackResultViewController.view}]];

    [self.pageViewControllerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:@{@"view" : self.trackResultViewController.view}]];

    [self.trackResultViewController didMoveToParentViewController:self];

    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.searchResultsTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    
    NSString* keyword = userManager.lastSearchKeyword;
    if(keyword) {
        [self makeSearchRequestWithKeyword:keyword];
        self.searchField.text = keyword;
    }

    self.historyPlaylist = [MFPlaylistItem MR_findFirstByAttribute:@"itemId" withValue:@"MF_IDENTIFICATION_HISTORY_PLAYLIST"];
    if (!self.historyPlaylist) {
        self.historyPlaylist = [MFPlaylistItem MR_createEntity];
        self.historyPlaylist.itemId = @"MF_IDENTIFICATION_HISTORY_PLAYLIST";
        self.historyPlaylist.songs = [[NSOrderedSet alloc] init];
        self.historyPlaylist.isPrivate = YES;
    }
    self.historyPlaylist.title = NSLocalizedString(@"Identification History", nil);
    _averageLogoHeight = [[UIScreen mainScreen] bounds].size.width*240.0/320.0;
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.buttonsSetUp) {
        [self.addTrackView layoutSubviews];
        [self.identifyView layoutSubviews];
        self.buttonsSetUp = YES;
        self.linkButton.layer.cornerRadius = self.linkButton.bounds.size.width/2.0;
        self.listenButton.layer.cornerRadius = self.listenButton.bounds.size.width/2.0;
        self.searchAddButton.layer.cornerRadius = self.searchAddButton.bounds.size.width/2.0;
        
        self.linkButton.layer.borderWidth = 1.0;
        self.linkButton.layer.borderColor = [UIColor colorWithRGBHex:0x1AC564].CGColor;
        self.linkButton.layer.backgroundColor = [UIColor colorWithRGBHex:0x1AC564].CGColor;
        
        self.listenButton.layer.borderWidth = 1.0;
        self.listenButton.layer.borderColor = [UIColor colorWithRGBHex:0xFD8D16].CGColor;
        self.listenButton.layer.backgroundColor = [UIColor colorWithRGBHex:0xFD8D16].CGColor;
        
        self.searchAddButton.layer.borderWidth = 1.0;
        self.searchAddButton.layer.borderColor = [UIColor colorWithRGBHex:0x186FFF].CGColor;
        self.searchAddButton.layer.backgroundColor = [UIColor colorWithRGBHex:0x186FFF].CGColor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if (!self.listenAgainButton.hidden && _shouldStartRecognizeImmediatelyAfterViewAppeared) {
        [self startRecognitionImediately];
    }
    _shouldStartRecognizeImmediatelyAfterViewAppeared = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)linkButtonTapped:(id)sender {
    self.linkView.alpha = 0.0;
    self.linkView.hidden = NO;
    [self.linkField becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.addTrackView.alpha = 0.0;
        self.linkView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.addTrackView.hidden = YES;
    }];
}

- (IBAction)listenButtonTapped:(id)sender {
    self.identifyingLabel.hidden = NO;
    self.identifiedLabel.hidden = YES;
    self.listenAgainButton.hidden = YES;
    [[MFRecognitionManager sharedInstance] identify];
    [MFRecognitionManager sharedInstance].delegate = self;
    [self prepareForIdentifying];

    self.identifyView.alpha = 0.0;
    self.identifyView.hidden = NO;
    self.vuView.hidden = NO;
    self.pageViewControllerContainer.hidden = YES;
    self.noResultsFoundLabel.hidden = YES;
    [UIView animateWithDuration:0.1 animations:^{
        self.addTrackView.alpha = 0.0;
        self.identifyView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.addTrackView.hidden = YES;
    }];
}

- (void)startRecognitionImediately{
    if (!self.listenAgainButton.hidden) {
        self.identifyingLabel.hidden = NO;
        self.identifiedLabel.hidden = YES;
        self.listenAgainButton.hidden = YES;
        [[MFRecognitionManager sharedInstance] identify];
        [MFRecognitionManager sharedInstance].delegate = self;
        [self prepareForIdentifying];

        self.identifyView.hidden = NO;
        self.vuView.hidden = NO;
        self.pageViewControllerContainer.hidden = YES;
        self.noResultsFoundLabel.hidden = YES;
        self.addTrackView.hidden = YES;
    }
}

- (IBAction)searchButtonTapped:(id)sender {
    self.searchView.alpha = 0.0;
    self.searchView.hidden = NO;
    [self.searchField becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.addTrackView.alpha = 0.0;
        self.searchView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.addTrackView.hidden = YES;
    }];
}

- (IBAction)closeButtonTapped:(id)sender {
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.view.alpha = 0.0;
//        self.blurView.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//        [self.blurView removeFromSuperview];
//        [self removeFromParentViewController];
//    }];
}

-(void) idEndedWithTrackName:(NSString *)name artist:(NSString *)artist error:(NSError *)error{
    if (!error) {
        [[IRNetworkClient sharedInstance] findTrackByName:name artist:artist SuccessBlock:^(NSDictionary *dictionary) {
            NSMutableArray *tempTracks = [[dataManager convertAndAddTracksToDatabase:@[dictionary]]mutableCopy];
            if (tempTracks.count) {
                NSMutableOrderedSet* songs = [self.historyPlaylist.songs mutableCopy];
                [songs insertObject:tempTracks[0] atIndex:0];
                self.historyPlaylist.songs = [songs copy];
                [self showRecognitionResultWithTracks:tempTracks];
                [[MFRecognitionManager sharedInstance] stopAudioProcess];
            } else {
                [self notFound];
                [[MFRecognitionManager sharedInstance] stopAudioProcess];
            }
        } failureBlock:^(NSString *errorMessage) {
            [[MFMessageManager sharedInstance] showErrorMessage:errorMessage inViewController:self.tabBarController];
            [self notFound];
            [[MFRecognitionManager sharedInstance] stopAudioProcess];
        }];
    } else {
        [self notFound];
        [[MFRecognitionManager sharedInstance] stopAudioProcess];
    }
}

- (void)showRecognitionResultWithTracks:(NSArray*)tracks{
    self.vuView.hidden = YES;
    self.identifyingLabel.hidden = YES;
    self.identifiedLabel.hidden = NO;
    self.listenAgainButton.hidden = NO;
    self.pageViewControllerContainer.hidden = NO;
    self.trackResultViewController.trackItem = tracks[0];
}

- (void)notFound{
//    [self showRecognitionResultWithTracks:self.searchResults];
    self.vuView.hidden = YES;
    self.identifyingLabel.hidden = YES;
    self.identifiedLabel.hidden = NO;
    self.listenAgainButton.hidden = NO;
    self.noResultsFoundLabel.hidden = NO;
    self.pageViewControllerContainer.hidden = YES;
}

- (IBAction)listenAgainButtonTapped:(id)sender {
    [self prepareForIdentifying];

    self.identifyingLabel.hidden = NO;
    self.identifiedLabel.hidden = YES;
    self.listenAgainButton.hidden = YES;
    self.noResultsFoundLabel.hidden = YES;
    self.vuView.hidden = NO;
    self.pageViewControllerContainer.hidden = YES;
    [[MFRecognitionManager sharedInstance] identify];
    [MFRecognitionManager sharedInstance].delegate = self;
}

- (void) prepareForIdentifying{
    _averageLevel = 0.0;
    _averageCount = 0;
    _lastLevel1 = 0.0;
    _lastLevel2 = 0.0;
    _lastLevel3 = 0.0;
    _lastLevel4 = 0.0;
    _lastLevel5 = 0.0;
}
-(void) RMSDidUpdateByValue:(float)value{
    if (value>0.0&&value<1.0) {

        _averageLevel = (_averageLevel*_averageCount + value)/(_averageCount+1);
        _averageCount++;

        float flatedValue = (_lastLevel5*0.25 + _lastLevel4*0.4 + _lastLevel3*0.55 + _lastLevel2*0.7 + _lastLevel1*0.85 + value)/(1+0.85+0.7+0.55+0.4+0.25);

        _lastLevel5=_lastLevel4;
        _lastLevel4=_lastLevel3;
        _lastLevel3=_lastLevel2;
        _lastLevel2=_lastLevel1;
        _lastLevel1=value;

        if (_averageCount>3) {
            float interp;

            interp = _averageLogoHeight + log10f(flatedValue/_averageLevel)*_averageLogoHeight*1.5;
            self.logoSize.constant = interp;
        } else {
            self.logoSize.constant = _averageLogoHeight;
        }

    }
}

- (IBAction)cancelLinkButtonTapped:(id)sender {
    self.addTrackView.alpha = 0.0;
    self.addTrackView.hidden = NO;
    [self.linkField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.addTrackView.alpha = 1.0;
        self.linkView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.linkView.hidden = YES;
    }];
}

- (IBAction)cancelSearchButtonTapped:(id)sender {
    self.addTrackView.alpha = 0.0;
    self.addTrackView.hidden = NO;
    [self.searchField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.addTrackView.alpha = 1.0;
        self.searchView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.searchView.hidden = YES;
    }];
}
- (IBAction)cancelIdentifyButtonTapped:(id)sender {
    self.addTrackView.alpha = 0.0;
    self.addTrackView.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.addTrackView.alpha = 1.0;
        self.identifyView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.identifyView.hidden = YES;
    }];
}

- (IBAction)linkViewTapped:(id)sender {
    [self.linkField resignFirstResponder];
}

- (IBAction)searchTableTapped:(id)sender {
    //[self.searchField resignFirstResponder];
}

- (IBAction)linkFieldEndOnExit:(id)sender {
    [self.linkField resignFirstResponder];
}

- (IBAction)searchFieldEndOnExit:(id)sender {
    [self.searchField resignFirstResponder];
}

- (IBAction)searchFieldEditingDidChanged:(id)sender {
    [self makeSearchRequestWithKeyword:self.searchField.text];
}

- (void)makeSearchRequestWithKeyword:(NSString *)keyword
{
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched parameters:@{FBSDKAppEventParameterNameSearchString : keyword}];
    userManager.lastSearchKeyword = keyword;
    [[IRNetworkClient sharedInstance] searchWithKeyword:keyword searchType:@"timelines" success:^(NSDictionary *dictionary) {
        NSMutableArray *tempTracks = [[dataManager convertAndAddTracksToDatabase:dictionary[@"timelines"]]mutableCopy];
        self.searchResults = tempTracks;
        
        [self.searchResultsTableView reloadData];
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellID = @"PlaylistTrackCell";
    
    PlaylistTrackCell *cell = (PlaylistTrackCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistTrackCell" owner:nil options:nil] lastObject];
    }
    cell.hideDefaultArtwork = YES;
    [cell setIsDefaultTrack:NO];
    //[cell setIsMyMusic:NO];
    cell.backgroundColor = [UIColor clearColor];
    cell.separatorView.hidden = YES;
    cell.undoRemoveView.hidden = YES;
    [cell.showMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.isDarkBackGround = YES;
    cell.playlistTrackCellDelegate = self;
    MFTrackItem* track = self.searchResults[indexPath.row];
    [cell setTrack:track];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didTouchThumb:(MFTrackItem *)track{
    NSUInteger index = [self.searchResults indexOfObject:track];
    if (![playerManager.currentTrack isEqual:self.searchResults[index]]) {
        [playerManager playSingleTrack:self.searchResults[index]];
    }
    else if ([playerManager playing]) {
        [playerManager pauseTrack];
    }
    else {
        [playerManager resumeTrack];
    }
}

- (void)shouldShowTrackInfo:(MFTrackItem *)track{
    self.trackItem = track;
    [self showSharing];
}

- (void)didSelectAddTrack:(MFTrackItem*)track{
    PlaylistsViewController *playlistsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"playlistsViewController"];
    playlistsVC.trackToAdd = track;

    [self.navigationController pushViewController:playlistsVC animated:YES];
}

- (void)didSelectShareTrack:(MFTrackItem*)track{
    self.trackItem = track;
    [self showSharing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.searchResultsTableView) {
        [self.searchField resignFirstResponder];
    }
}

- (IBAction)showIdHistory:(id)sender {
    PlaylistTracksViewController *playlistTracksVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"playlistTracksViewController"];
    playlistTracksVC.playlist = self.historyPlaylist;
    playlistTracksVC.isDefaultPlaylist = NO;
    playlistTracksVC.isHistoryPlaylist = YES;
    playlistTracksVC.userExtId = userManager.userInfo.extId;
    playlistTracksVC.isMyMusic = NO;
    [self.navigationController pushViewController:playlistTracksVC animated:YES];
}

@end
