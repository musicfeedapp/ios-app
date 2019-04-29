//
//  SearchViewController.h
//  botmusic
//
//  Created by Supervisor on 17.08.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"
#import "SuggestionCell.h"
#import "AKSegmentedControl.h"

@interface SearchViewController : AbstractViewController

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

@property (nonatomic, weak) IBOutlet UIButton *allButton;
@property (nonatomic, weak) IBOutlet UIButton *tracksButton;
@property (nonatomic, weak) IBOutlet UIButton *artistsButton;
@property (nonatomic, weak) IBOutlet UIButton *peopleButton;
@property (nonatomic, weak) IBOutlet UIButton *playlistsButton;

@property (nonatomic, weak) IBOutlet UITableView *resultsTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *resultsTableViewBottomSpaceConstraint;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsTextLabel;

@property (nonatomic, copy) NSArray *allTracksArray;
@property (nonatomic, strong) NSMutableArray *youtubeTracksArray;
@property (nonatomic, strong) NSMutableArray *soundcloudTracksArray;
@property (nonatomic, strong) NSMutableArray *otherTracksArray;

@property (nonatomic, strong) NSMutableArray *allYoutubeTracksArray;
@property (nonatomic, strong) NSMutableArray *allSoundcloudTracksArray;
@property (nonatomic, strong) NSMutableArray *allOtherTracksArray;


@property (nonatomic, copy) NSArray *allArtistsArray;
@property (nonatomic, copy) NSArray *allPeopleArray;
@property (nonatomic, copy) NSArray *allPlaylistsArray;

@property (nonatomic, copy) NSArray *tracksArray;
@property (nonatomic, copy) NSArray *artistsArray;
@property (nonatomic, copy) NSArray *peopleArray;
@property (nonatomic, copy) NSArray *playlistsArray;

- (IBAction)didTouchUpAllButton:(id)sender;
- (IBAction)didTouchUpTracksButton:(id)sender;
- (IBAction)didTouchUpArtistsButton:(id)sender;
- (IBAction)didTouchUpPeopleButton:(id)sender;
- (IBAction)didTouchUpPlaylistsButton:(id)sender;

- (IBAction)didTouchUpSearchButton:(id)sender;
- (IBAction)didTouchUpCloseButton:(id)sender;

@end
