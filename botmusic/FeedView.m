//
//  FeedView.m
//  botmusic
//
//  Created by Dzionis Brek on 19.03.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FeedView.h"
#import "MFRecognitionManager.h"
#import "MFSuggestionsFilterTypeTableViewCell.h"

@implementation FeedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib
{
    //[self setFilterArray];
    
    //[self addBarMenu];
    
    //[self addNavigationTitle];
    self.filtersTableView.dataSource = self;
    self.filtersTableView.delegate = self;
    UINib *filtertypeCellNib = [UINib nibWithNibName:@"MFSuggestionsFilterTypeTableViewCell" bundle:nil];
    [self.filtersTableView registerNib:filtertypeCellNib forCellReuseIdentifier:@"MFSuggestionsFilterTypeTableViewCell"];
    self.selectedFilterIndex = 0;
    if (userManager.isLoggedIn) {
        self.filters = @[NSLocalizedString(@"Musicfeed", nil), NSLocalizedString(@"My Posts", nil), NSLocalizedString(@"Trending", nil), NSLocalizedString(@"Video only", nil), NSLocalizedString(@"Audio only", nil)];
    } else {
        self.filters = @[NSLocalizedString(@"Musicfeed", nil), NSLocalizedString(@"Trending", nil), NSLocalizedString(@"Video only", nil), NSLocalizedString(@"Audio only", nil)];
    }
    self.headerLabel.text = self.filters[0];
}

+(FeedView*)createFeedView
{
    FeedView *feedView = [[[NSBundle mainBundle] loadNibNamed:@"FeedView" owner:nil options:nil] objectAtIndex:0];
    [feedView setFrame:[[UIScreen mainScreen]bounds]];
    [feedView.tableView setContentInset:UIEdgeInsetsMake(520, 0, 500, 0)];
    feedView.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(520, 0.0f, 500, 0.0f);
    return feedView;
}

#pragma mark - View Initials

-(void)setFilterArray
{
    NSMutableArray *array=[NSMutableArray array];
    
    [array addObject:[feedTypeAll capitalizedString]];
    
    if(settingsManager.isConnectYoutube)
    {
        [array addObject:[feedTypeYoutube capitalizedString]];
    }
    if(settingsManager.isConnectSoundCloud)
    {
        [array addObject:[feedTypeSoundcloud capitalizedString]];
    }
    if(settingsManager.isConnectSpotify)
    {
        [array addObject:[feedTypeSpotify capitalizedString]];
    }
    if(settingsManager.isConnectGrooveshark)
    {
        [array addObject:[feedTypeGrooveshark capitalizedString]];
    }
    if(settingsManager.isConnectShazam)
    {
        [array addObject:[feedTypeShazam capitalizedString]];
    }
    
    _feedTypeArray=array;
    
}
-(void)addBarMenu
{
    NSMutableArray *menuItems=[@[] mutableCopy];
    for(int i=0;i<_feedTypeArray.count;i++)
    {
        NSString *feedType=_feedTypeArray[i];
        
        REMenuItem *item = [[REMenuItem alloc] initWithTitle:feedType
                                                       subtitle:nil
                                                          image:nil
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self didSelectItem:item];
                                                         }];
        [item setTag:i];
        [menuItems addObject:item];
    }
    
    _menu=[[REMenu alloc]initWithItems:menuItems];
    _menuReady=YES;
    
    FeedView *this=self;
    [_menu setCloseCompletionHandler:^{
        this.menuReady=YES;
    }];
    
}
-(void)addNavigationTitle
{
    _navigationTitle=[NavigationTitle createNavigationTitle];
    
    CGRect frame=_navigationTitle.frame;
    frame.origin=CGPointMake(0, 31);
    [_navigationTitle setFrame:frame];
    
    [_navigationTitle setNavigationTitle:_feedTypeArray[0] andState:NavigationTitleStateDown];
    
    [_navigationTitle setDelegate:self];
    
    [[self viewWithTag:10]insertSubview:_navigationTitle atIndex:0];
}

#pragma mark - Actions

-(void)didTapAtTitle
{
//    if(_menuReady)
//    {
//        [_viewForMenu setHidden:!_viewForMenu.hidden];
//        _menuReady=NO;
//        
//        if(_menu.isOpen)
//        {
//            [_menu closeWithCompletion:^{
//                _menuReady=YES;
//            }];
//            
//            [_navigationTitle setState:NavigationTitleStateDown];
//        }
//        else
//        {
//            [_navigationTitle setState:NavigationTitleStateUp];
//            
//            [_menu showFromRect:CGRectMake(0, 0,self.frame.size.width, 500) inView:_viewForMenu];
//            
//            _menuReady=YES;
//        }
//    }
}
-(void)didSelectItem:(REMenuItem*)item
{
    [_navigationTitle setNavigationTitle:_feedTypeArray[item.tag]];
    
    [_delegate didSelectFeedType:[(NSString*)_feedTypeArray[item.tag] lowercaseString]];
    
    //[_viewForMenu setHidden:!_viewForMenu.hidden];
    
    [_navigationTitle setState:NavigationTitleStateDown];
}

#pragma mark - IBActions

- (IBAction)topErrorButtonClicked:(id)sender {
    [MFNotificationManager postHideTopErrorNotification:self.topErrorViewLabel.text];

}


- (IBAction)didTouchUpSearchButton:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectSearch)]) {
        [_delegate didSelectSearch];
    }
}

- (IBAction)filterButtonTapped:(id)sender {
    [self toggleFilteringState];
}

- (void) toggleFilteringState{
    if (self.isInFilteringMode) {
        self.isInFilteringMode = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.filtersTableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.filtersTableView.hidden = YES;
        }];
    } else {
        self.isInFilteringMode = YES;
        self.filtersTableView.hidden = NO;
        self.filtersTableView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.filtersTableView.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filters.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MFSuggestionsFilterTypeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MFSuggestionsFilterTypeTableViewCell"];
    NSString* filter = self.filters[indexPath.row];
    cell.label.text = filter;
    if (self.selectedFilterIndex == indexPath.row) {
        cell.mark.hidden = NO;
        cell.label.textColor = cell.mark.textColor;
    } else {
        cell.mark.hidden = YES;
        cell.label.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedFilterIndex = indexPath.row;
    if (userManager.isLoggedIn) {
        if (self.selectedFilterIndex == 0) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeFeed];
        } else if (self.selectedFilterIndex == 1) {
            [self.delegate setFeedFilterType:MFFeedFilterTypePosts];
        } else if (self.selectedFilterIndex == 2) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeTrending];
        } else if (self.selectedFilterIndex == 3) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeVideoOnly];
        } else if (self.selectedFilterIndex == 4) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeAudioOnly];
        }
    } else {
        if (self.selectedFilterIndex == 0) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeFeed];
        } else if (self.selectedFilterIndex == 1) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeTrending];
        } else if (self.selectedFilterIndex == 2) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeVideoOnly];
        } else if (self.selectedFilterIndex == 3) {
            [self.delegate setFeedFilterType:MFFeedFilterTypeAudioOnly];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self toggleFilteringState];
    [self.filtersTableView reloadData];
    self.headerLabel.text = self.filters[indexPath.row];
}

@end
