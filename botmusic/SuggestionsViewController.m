
//
//  SuggestionsViewController.m
//  botmusic
//
//  Created by Supervisor on 12.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "SuggestionsViewController.h"
#import <UIColor+Expanded.h>
#import "MFNotificationManager.h"
#import "MFSuggestion+Behavior.h"
#import "MagicalRecord/MagicalRecord.h"


@interface SuggestionsViewController ()<UICollectionViewDelegate>

@property(nonatomic,weak)IBOutlet UIView *headerView;
@property(nonatomic,weak)IBOutlet UICollectionView *collectionView;
@property(nonatomic,weak)IBOutlet UIButton *menuButton;
@property(nonatomic,weak)IBOutlet UIButton *backButton;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)NSIndexPath *playingIndexPath;
@property(nonatomic,copy)NSMutableArray *suggestions;
@property(nonatomic,copy)NSArray *suggestionTracks;
@property(nonatomic,strong)NSArray *suggestionRequests;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeftConstraint;

@property (nonatomic, strong) NSMutableArray *suggestionUsers;
@property (nonatomic, strong) NSArray *suggestionUsersRequests;

-(IBAction)didTapAtMenuButton:(id)sender;
-(IBAction)didSelectBack:(id)sender;

@end

@implementation SuggestionsViewController

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
    
    [self setActivityViewSettings];

    
    [self setCollectionViewSettings];
    
    [self.headerView addGestureRecognizer:self.headerTapRecognizer];
    
    self.collectionViewLeftConstraint.constant = (int)[UIScreen mainScreen].bounds.size.width % 3;
    if (self.collectionViewLeftConstraint.constant!=0){
        self.collectionViewLeftConstraint.constant -=3;
    }
    
    NSString *notificationStatusBarTappedName = [MFNotificationManager nameForNotification:MFNotificationTypeStatusBarTapped];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTapOnHeader:)
                                                 name:notificationStatusBarTappedName
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    playerManager.videoPlayer.currentViewController = self;

    [self.collectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    _suggestions = [[self cachedSuggestions] mutableCopy];

    if (_suggestions.count == 0) {
        [self.activityView startAnimating];

    }
    [self suggestionRequest];

    if(self.isRedirectTo)
    {
        [self.menuButton setHidden:YES];
        [self.backButton setHidden:NO];
    }
    else
    {
        [self.menuButton setHidden:NO];
        [self.backButton setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [self updateCollectionViewFrame];
}

#pragma mark - UIPreparation

-(void)setActivityViewSettings{
    [self.activityView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2)];
    //[self.activityView startAnimating];
}

#pragma mark - Caching methods

- (NSArray *)cachedSuggestions
{
    return [MFSuggestion MR_findAllSortedBy:@"order" ascending:YES];
}

- (void)setCachedSuggestions:(NSArray *)suggestions
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

#pragma mark - Suggestions download

-(void)suggestionRequest
{
    [[IRNetworkClient sharedInstance]getSuggestionsWithEmail:userManager.userInfo.email
                                                       token:[userManager fbToken]
                                                successBlock:^(NSDictionary *suggestionArray)
                                                {
                                                    _suggestionRequests = suggestionArray[@"artists"];
                                                    _suggestionUsersRequests = suggestionArray[@"users"];
                                                    
                                                    [MFSuggestion MR_truncateAll];
                                                    _suggestions = [[dataManager convertAndAddSuggestionItemsToDatabase:suggestionArray[@"artists"]] mutableCopy];



                                                    [self.activityView stopAnimating];

                                                    [self setCachedSuggestions:_suggestions];

                                                    [_collectionView reloadData];

                                                    [self hideTopErrorViewWithMessage:self.kConnectedMessage];

                                                }
                                                failureBlock:^(NSString *errorMessage)
                                                {
                                                    [self.activityView stopAnimating];
                                                    
                                                    [self showAndKeepTopErrorViewWithMessage:self.kNetworkErrorMessage autohide:YES];
                                                }];
}

#pragma mark - CollectionView settings

-(void)setCollectionViewSettings
{
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellID"];
    
    [self setQuiltLayout];
    
    [self updateCollectionViewFrame];

    
    [self.collectionView reloadData];
}
-(void)setQuiltLayout
{
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = [self sizeOfNonselectedArtistCell];
}

#pragma mark - UICollectionView DataSoure

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _suggestions.count > 99 ? 99 : _suggestions.count;
    }
    else {
        return _suggestionUsers.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"CellID";
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    ArtistCell *artistCell=(ArtistCell*)[cell.contentView.subviews lastObject];
    
    if(artistCell==nil)
    {
        artistCell=[[[NSBundle mainBundle]loadNibNamed:@"ArtistCell" owner:nil options:nil]lastObject];
        artistCell.tag=1;
        [cell.contentView addSubview:artistCell];
    }
    
    MFSuggestion *suggestion;
    if (indexPath.section == 0) {
        suggestion = _suggestions[indexPath.row];
    }
    else {
        suggestion = _suggestionUsers[indexPath.row];
    }
    
    [artistCell setShowGradient:NO];
    [artistCell setArtistInfo:suggestion];
    [artistCell setIndexPath:indexPath];
    [artistCell setDelegate:self];
    
    if(_selectedIndexPath && _selectedIndexPath.row==indexPath.row)
    {
        [self setSize:[self sizeOfSelectedArtistCell] ofCollectionCell:cell];
        [artistCell setIsSelected:YES];
    }
    else
    {
        [self setSize:[self sizeOfNonselectedArtistCell] ofCollectionCell:cell];
        [artistCell setIsSelected:NO];
    }
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];
    UICollectionViewCell *selectedCell=[collectionView cellForItemAtIndexPath:_selectedIndexPath];
    
    ArtistCell *artistCell=(ArtistCell*)[cell.contentView.subviews lastObject];
    ArtistCell *selectedArtistCell=(ArtistCell*)[selectedCell.contentView.subviews lastObject];
    
    if(!artistCell.isSelected)
    {
        artistCell.isSelected=YES;
        selectedArtistCell.isSelected=NO;
        
        [collectionView performBatchUpdates:^{
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                
                                    [self setSize:[self sizeOfSelectedArtistCell] ofCollectionCell:cell];
                                    
                                    if(_selectedIndexPath)
                                    {
                                        [self setSize:[self sizeOfNonselectedArtistCell] ofCollectionCell:selectedCell];
                                    }
                                    
                                    _selectedIndexPath=indexPath;
                                }];
                            }
                                 completion:^(BOOL finised){
            
                                     selectedArtistCell.showGradient = YES;
            
                                     [self updateCollectionViewFrame];
                                     
                                     CGRect frame = cell.frame;
                                     CGRect cellFrameInSuperview = [_collectionView convertRect:frame toView:[_collectionView superview]];
                                     
                                     //Use maxY instead height because of navigation bar
                                     if(cellFrameInSuperview.origin.y + cellFrameInSuperview.size.height > CGRectGetMaxY(_collectionView.frame) - (_collectionView.contentInset.bottom)){
                                         [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath
                                                                     atScrollPosition:UICollectionViewScrollPositionBottom
                                                                             animated:YES];
                                     }
                                     else if (cellFrameInSuperview.origin.y < CGRectGetMinY(_collectionView.frame)){
                                         [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath
                                                                     atScrollPosition:UICollectionViewScrollPositionTop
                                                                             animated:YES];
                                     }
        }];
    }
}

#pragma mark - ArtistCell Delegate methods

-(void)didSelectPlay:(NSIndexPath *)indexPath
{
    if(_playingIndexPath!=indexPath)
    {
//        MFSuggestion *suggestion=_suggestions[indexPath.row];
//        _playingIndexPath=indexPath;
//        
//        [[IRNetworkClient sharedInstance]getSuggestionTimelinesWithArtistId:suggestion.identifier
//                                                                      email:userManager.userInfo.email
//                                                                      token:[userManager fbToken]
//                                                               successBlock:^(NSArray *timelineArray)
//         {
//            
//         }
//                                                               failureBlock:^(NSString *errorMessage)
//         {
//             [NSObject showErrorConnectionMessage];
//         }];
        
        NSDictionary *dictionary;
        if (indexPath.section == 0) {
            dictionary = _suggestionRequests[indexPath.row];
        }
        else {
            dictionary = _suggestionUsersRequests[indexPath.row];
        }
        NSArray *timelineArray=dictionary[@"timelines"];
        
        NSMutableArray* tempTracks = [[dataManager convertAndAddTracksToDatabase:timelineArray] mutableCopy];
        
        _suggestionTracks=tempTracks;
        _playingIndexPath=indexPath;
        
        [self.container setPlayerViewHidden:NO];
        [playerManager stopTrack];
        [playerManager playPlaylist:_suggestionTracks fromIndex:0];
        [saver setTrackSource:MFTracksSourceNone];
        
        [self updateCollectionViewFrame];
    }
    else
    {
        [playerManager resumeTrack];
    }
}
-(void)didSelectPause:(NSIndexPath *)indexPath
{
    [playerManager pauseTrack];
}
-(void)didSelectFollow:(NSIndexPath *)indexPath
{
    MFSuggestion *suggestion;
    if (indexPath.section == 0) {
        suggestion = _suggestions[indexPath.row];
    }
    else {
        suggestion = _suggestionUsers[indexPath.row];
    }

    if(suggestion.is_followed)
    {
        NSDictionary *proposalsDictionary = @{@"ext_id" : suggestion.ext_id,
                                              @"followed" : @"false"};
        
        [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                          token:[userManager fbToken]
                                                      proposals:@[proposalsDictionary]
                                                   successBlock:^{}
                                                   failureBlock:^(NSString *errorMessage){}];
    }
    else
    {
        [[IRNetworkClient sharedInstance]followSuggestionWithArtistId:suggestion.identifier
                                                         successBlock:^{}
                                                         failureBlock:^(NSString *errorMessage){
                                                             [NSObject showErrorConnectionMessage];
                                                         }];
    }
    
    suggestion.is_followed = !suggestion.is_followed;
    
    if (indexPath.section == 0) {
        [self.suggestions replaceObjectAtIndex:indexPath.row withObject:suggestion];
    }
    else {
        [self.suggestionUsers replaceObjectAtIndex:indexPath.row withObject:suggestion];
    }
    
    //[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - TrackSource Delegate methods

-(void)loginSoundcloud:(UIViewController *)loginController
{
    [self presentViewController:loginController animated:YES completion:nil];
}

#pragma mark -RFQuiltLayout Delegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *cell =[self.collectionView cellForItemAtIndexPath:indexPath];
//    
//    ArtistCell *artistCell=(ArtistCell*)[cell.contentView.subviews lastObject];
    
    if(_selectedIndexPath && _selectedIndexPath.row==indexPath.row && _selectedIndexPath.section == indexPath.section) //artistCell.isSelected)
    {
        return CGSizeMake(2, 2);
    }
    else
    {
        return CGSizeMake(1, 1);
    }
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Abstract View Controller methods

- (void)searchWillShow
{
    [self.collectionView setHidden:YES];
}
- (void)searchWillHide
{
    [self.collectionView setHidden:NO];
}

#pragma mark - Helpers

- (CGSize)sizeOfNonselectedArtistCell
{
    return CGSizeMake([ArtistCell sizeOfArtistCell], [ArtistCell sizeOfArtistCell]);
}
- (CGSize)sizeOfSelectedArtistCell
{
    return CGSizeMake(2*[ArtistCell sizeOfArtistCell], 2*[ArtistCell sizeOfArtistCell]);
}
- (void)setSize:(CGSize)size ofCollectionCell:(UICollectionViewCell*)cell
{
    CGRect frame = cell.frame;
    frame.size =size;
    cell.frame = frame;
    
    ArtistCell *artistCell=[cell.contentView.subviews lastObject];
    frame = artistCell.frame;
    frame.size =size;
    artistCell.frame = frame;
}
- (void)updateCollectionViewFrame
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.tabBarController.tabBar.bounds.size.height, 0.0);
    _collectionView.contentInset = contentInsets;
    _collectionView.scrollIndicatorInsets = contentInsets;

}

#pragma mark - MFSideContainer Menu

-(IBAction)didTapAtMenuButton:(id)sender
{
    [self.container toggleLeftSideMenuCompletion:nil];
}
-(IBAction)didSelectBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notifications


#pragma mark - Set Reachability notifications





#pragma mark - Base class implementations

- (void)didTapOnHeader:(id)sender
{
    if ([self.collectionView numberOfItemsInSection:0] > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

@end
