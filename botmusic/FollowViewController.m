//
//  FollowViewController.m
//  botmusic
//
//  Created by Илья Романеня on 09.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "FollowViewController.h"
#import <UIColor-Utilities/UIColor+Expanded.h>
#import "UIView+Utilities.h"
#import "MainViewController.h"

@interface FollowViewController ()

@end

@implementation FollowViewController

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
	// Do any additional setup after loading the view.
    
    [self.nextButton setBackgroundImage:[[UIImage imageNamed:@"common-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)] forState:UIControlStateNormal];
    
    UINib *followCellNib = [UINib nibWithNibName:@"FollowCell" bundle:nil];
    [self.tableView registerNib:followCellNib
         forCellReuseIdentifier:@"FollowCell"];
    
    self.friendsFollowItems = [NSMutableArray array];
    self.artistsFollowItems = [NSMutableArray array];
    
    [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance] proposalsWithEmail:userManager.userInfo.email
                                                   token:[userManager fbToken]
                                           onlyFollowing:@(NO)
                                            successBlock:^(NSDictionary* proposals)
     {
         [self.activityIndicator stopAnimating];
         [self.friendsFollowItems removeAllObjects];
         [self.artistsFollowItems removeAllObjects];
         NSArray* friendProposals = [proposals objectForKey:@"friends"];
         NSArray* artistProposals = [proposals objectForKey:@"artists"];
         self.friendsFollowItems = [[dataManager convertAndAddFollowItemsToDatabase:friendProposals] mutableCopy];
         self.artistsFollowItems = [[dataManager convertAndAddFollowItemsToDatabase:artistProposals] mutableCopy];

        [self.tableView reloadData];
     }
                                            failureBlock:^(NSString* errorString)
     {
         [self.activityIndicator stopAnimating];
         [NSObject showErrorConnectionMessage];
     }];
    
    //#ifdef DEBUG
    //    MFFollowItem* artistItem1 = [[MFFollowItem alloc] initWithDictionary:@{@"name" : @"The Prodigy",
    //                                                                           @"subName" : @"artist",
    //                                                                           @"picture" : @"http://userserve-ak.last.fm/serve/_/27856061/The%2BProdigy%2Bprodigy.jpg",
    //                                                                           @"following" : @YES}];
    //    MFFollowItem* artistItem2 = [[MFFollowItem alloc] initWithDictionary:@{@"name" : @"The Chemical Brothers",
    //                                                                           @"subName" : @"artist",
    //                                                                           @"picture" : @"http://zort.ru/media/uploads/images/artists/chemical-brothers_284.jpg",
    //                                                                           @"following" : @(arc4random()%2)}];
    //    self.artistsFollowItems = [NSMutableArray arrayWithObjects:artistItem1, artistItem2, nil];
    //
    //    MFFollowItem* friendItem1 = [[MFFollowItem alloc] initWithDictionary:@{@"name" : @"Mama ASD",
    //                                                                           @"subName" : @"yourmmum",
    //                                                                           @"picture" : @"http://www.geekpeeks.com/wp-content/uploads/2011/07/Wonder-Woman-AP.jpg",
    //                                                                           @"following" : @YES}];
    //    MFFollowItem* friendItem2 = [[MFFollowItem alloc] initWithDictionary:@{@"name" : @"Papa QWE",
    //                                                                           @"subName" : @"bigdaddy",
    //                                                                           @"picture" : @"http://upload.wikimedia.org/wikipedia/commons/8/83/Young_man_with_dimples.jpg",
    //                                                                           @"following" : @(arc4random()%2)}];
    //    self.friendsFollowItems = [NSMutableArray arrayWithObjects:friendItem1, friendItem2, nil];
    //#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Talbe View delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    
    if (self.artistsFollowItems.count)
    {
        sections++;
    }
    if (self.friendsFollowItems.count)
    {
        sections++;
    }
    
    return sections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((self.friendsFollowItems.count) && (self.artistsFollowItems.count))
    {
        switch (indexPath.section) {
            case 0:
                return [self cellForArtistSectionInTableView:tableView indexPath:indexPath];
                break;
            case 1:
                return [self cellForPeopleSectionInTableView:tableView indexPath:indexPath];
            default:
                break;
        }
    }
    else
    {
        if (self.artistsFollowItems.count)
        {
            return [self cellForArtistSectionInTableView:tableView indexPath:indexPath];
        }
        if (self.friendsFollowItems.count)
        {
            return [self cellForPeopleSectionInTableView:tableView indexPath:indexPath];
        }
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((self.friendsFollowItems.count) && (self.artistsFollowItems.count))
    {
        switch (section) {
            case 0:
                return self.artistsFollowItems.count;
                break;
            case 1:
                return self.friendsFollowItems.count;
            default:
                break;
        }
    }
    else
    {
        if (self.artistsFollowItems.count)
        {
            return self.artistsFollowItems.count;
        }
        if (self.friendsFollowItems.count)
        {
            return self.friendsFollowItems.count;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([tableView numberOfSections] == section + 1)
    {
        return 8;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    view.backgroundColor = [UIColor colorWithRGBHex:kBackgroundColor];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, tableView.frame.size.width, 25)];
    [view addSubview:label];
    label.textColor = [UIColor colorWithRGBHex:kActiveColor];
    label.font = [UIFont fontWithName:kMainFontFamilyName size:20];
    
    if ((self.friendsFollowItems.count) && (self.artistsFollowItems.count))
    {
        switch (section) {
            case 0:
            {
                label.text = NSLocalizedString(@"Artists",nil);
                break;
            }
                
            case 1:
            {
                label.text = NSLocalizedString(@"Friends",nil);
                break;
            }
                break;
            default:
                break;
        }
    }
    else
    {
        if (self.artistsFollowItems.count)
        {
            label.text = NSLocalizedString(@"Artists",nil);
        }
        if (self.friendsFollowItems.count)
        {
            label.text = NSLocalizedString(@"Friends",nil);
        }
    }
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ((section == tableView.numberOfSections - 1) || (tableView.numberOfSections == 0))
    {
        return [UIView new];
    }
    return nil;
}


#pragma mark - Follow Cells delegate

- (void)changeFollowing:(FollowCell *)sender
{
    MFFollowItem* followItem;
    
    if ((self.friendsFollowItems.count) && (self.artistsFollowItems.count))
    {
        switch (sender.indexPath.section) {
            case 0:
                followItem = self.artistsFollowItems[sender.indexPath.row];
                break;
            case 1:
                followItem = self.friendsFollowItems[sender.indexPath.row];
                break;
                
            default:
                break;
        }
    }
    else
    {
        if (self.artistsFollowItems.count)
        {
            followItem = self.artistsFollowItems[sender.indexPath.row];
        }
        if (self.friendsFollowItems.count)
        {
            followItem = self.friendsFollowItems[sender.indexPath.row];
        }
    }
    
    if (followItem)
    {
        followItem.isFollowed = !followItem.isFollowed;
    }
}

- (BOOL)following:(FollowCell *)sender
{
    MFFollowItem* followItem;
    
    if ((self.friendsFollowItems.count) && (self.artistsFollowItems.count))
    {
        switch (sender.indexPath.section) {
            case 0:
                followItem = self.artistsFollowItems[sender.indexPath.row];
                break;
            case 1:
                followItem = self.friendsFollowItems[sender.indexPath.row];
                break;
                
            default:
                break;
        }
    }
    else
    {
        if (self.artistsFollowItems.count)
        {
            followItem = self.artistsFollowItems[sender.indexPath.row];
        }
        if (self.friendsFollowItems.count)
        {
            followItem = self.friendsFollowItems[sender.indexPath.row];
        }
    }
    
    if (followItem)
    {
        return followItem.isFollowed;
    }
    
    return 0;
}

#pragma mark - Follow Cells

- (UITableViewCell*)cellForPeopleSectionInTableView:(UITableView *)tableView indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FollowCell";
    
    FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell setFollowItem:self.friendsFollowItems[indexPath.row] buttonHidden:NO];
    cell.indexPath = indexPath;
    
    if ((indexPath.row == 0) && (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
    {
        [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight) radius:CGSizeMake(3, 3)];
    }
    else
    {
        if (indexPath.row == 0)
        {
            [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:CGSizeMake(3, 3)];
        }
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        {
            [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) radius:CGSizeMake(3, 3)];
        }
    }
    return cell;
}

- (UITableViewCell*)cellForArtistSectionInTableView:(UITableView *)tableView indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"FollowCell";
    
    FollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell setFollowItem:self.artistsFollowItems[indexPath.row] buttonHidden:NO];
    cell.indexPath = indexPath;
    
    if ((indexPath.row == 0) && (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1))
    {
        [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight) radius:CGSizeMake(3, 3)];
    }
    else
    {
        if (indexPath.row == 0)
        {
            [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:CGSizeMake(3, 3)];
        }
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        {
            [[cell viewWithTag:followCellMainViewTag] applyRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) radius:CGSizeMake(3, 3)];
        }
    }
    return cell;
}

#pragma mark - IBActions
- (IBAction)nextTap:(id)sender
{
    MainViewController* mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    
    NSMutableArray* proposals = [NSMutableArray array];
    [proposals addObjectsFromArray:self.friendsFollowItems];
    [proposals addObjectsFromArray:self.artistsFollowItems];
    
    self.nextButton.hidden = YES;
    self.tableView.hidden = YES;
    [self.activityIndicator startAnimating];
    [[IRNetworkClient sharedInstance] putProposalsWithEmail:userManager.userInfo.email
                                                      token:[userManager fbToken]
                                                  proposals:[MFFollowItem idsFromFollowItems:proposals]
                                               successBlock:^
     {
         [self.activityIndicator stopAnimating];
         self.nextButton.hidden = NO;
         self.tableView.hidden = NO;
         [self presentViewController:mainVC
                            animated:YES
                          completion:nil];
         
     }
                                               failureBlock:^(NSString* errorMessage)
     {
         [self.activityIndicator stopAnimating];
         self.nextButton.hidden = NO;
         self.tableView.hidden = NO;
         [NSObject showErrorConnectionMessage];
         
         [self presentViewController:mainVC
                            animated:YES
                          completion:nil];
     }];
    
    
}
@end
