//
//  ShareViewController.m
//  botmusic
//
//  Created by Илья Романеня on 16.01.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "ShareViewController.h"
#import <ItunesSearch.h>
#import <Social/Social.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kShareCells 5

@interface ShareViewController ()

@end

@implementation ShareViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Talbe View delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 140;
    }
    else if (indexPath.row == kShareCells)
    {
        return 0;
    }
    else
    {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *shareHeaderCellIdentifier = @"ShareHeaderCell";
    static NSString *shareItemCellIdentifier = @"ShareItemCell";
    
    switch (indexPath.row)
    {
        case 0:
        {
            ShareHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:shareHeaderCellIdentifier forIndexPath:indexPath];
            cell.delegate = self;
            
            [cell refreshViews];
            
            return cell;
        }
        case 1:
        {
            ShareItemCell *cell = [tableView dequeueReusableCellWithIdentifier:shareItemCellIdentifier forIndexPath:indexPath];
            cell.label.text = !self.added ? @"Add to favorites" : @"Remove from favorites";
            [cell.itemImageView setImage:[UIImage imageNamed:@"share-tracks.png"]];
            return cell;
        }
        case 2:
        {
            ShareItemCell *cell = [tableView dequeueReusableCellWithIdentifier:shareItemCellIdentifier forIndexPath:indexPath];
            cell.label.text = @"Send to a Friend";
            [cell.itemImageView setImage:[UIImage imageNamed:@"share-friend.png"]];
            return cell;
        }
        case 3:
        {
            ShareItemCell *cell = [tableView dequeueReusableCellWithIdentifier:shareItemCellIdentifier forIndexPath:indexPath];
            cell.label.text = @"Open in iTunes";
            [cell.itemImageView setImage:[UIImage imageNamed:@"share-itunes.png"]];
            return cell;
        }
        case 4:
        {
            ShareItemCell *cell = [tableView dequeueReusableCellWithIdentifier:shareItemCellIdentifier forIndexPath:indexPath];
            cell.label.text = @"Open in Youtube";
            [cell.itemImageView setImage:[UIImage imageNamed:@"share-youtube.png"]];
            return cell;
        }
        case kShareCells:
        {
            return [UITableViewCell new];
        }
        default:
            break;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kShareCells + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ShareItemCell* itemCell = ((ShareItemCell*)[tableView cellForRowAtIndexPath:indexPath]);
    
    switch (indexPath.row)
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            itemCell.processing = YES;
            
            if (!self.added)
            {
                [[IRNetworkClient sharedInstance] addTrackByFeedItemId:self.feedItem.itemId
                                                             withEmail:userManager.userInfo.email
                                                                 token:[userManager fbToken]
                                                          successBlock:^(NSArray* feedArrayData)
                 {
                     itemCell.processing = NO;
                 }
                                                          failureBlock:^(NSString* errorMessage)
                 {
                     itemCell.processing = NO;
                     [NSObject showErrorConnectionMessage];
                 }];
            }
            else
            {
                [[IRNetworkClient sharedInstance] removeTrackByFeedItemId:self.feedItem.itemId
                                                                withEmail:userManager.userInfo.email
                                                                    token:[userManager fbToken]
                                                             successBlock:^(NSDictionary* feedArrayData)
                 {
                     itemCell.processing = NO;
                 }
                                                             failureBlock:^(NSString* errorMessage)
                 {
                     itemCell.processing = NO;
                     [NSObject showErrorConnectionMessage];
                 }];
            }
            break;
            
        }
        case 2:
        {
            UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[self.feedItem shareText]]
                                                                                     applicationActivities:nil];
            
            activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                 UIActivityTypePostToTwitter,
                                                 UIActivityTypePostToWeibo,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeCopyToPasteboard,
                                                 UIActivityTypeAssignToContact,
                                                 UIActivityTypeSaveToCameraRoll,
                                                 UIActivityTypeAddToReadingList,
                                                 UIActivityTypePostToFlickr,
                                                 UIActivityTypePostToVimeo,
                                                 UIActivityTypePostToTencentWeibo,
                                                 UIActivityTypeAirDrop];
            [self presentViewController:activityVC animated:YES completion:nil];
            break;
        }
        case 3:
        {
            itemCell.processing = YES;
            
            NSString *searchTerm = [NSString stringWithFormat:@"%@ %@", self.feedItem.artist, self.feedItem.trackName];
            searchTerm = [searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            searchTerm = [searchTerm stringByReplacingOccurrencesOfString:@"\t" withString:@"+"];
            
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\[.*])|(\\(.*\\))" options:NSRegularExpressionCaseInsensitive error:&error];
            NSString *term = [regex stringByReplacingMatchesInString:searchTerm options:0 range:NSMakeRange(0, [searchTerm length]) withTemplate:@""];
            NSLogExt(@"%@", term);
            
            NSDictionary* params = @{@"term" : term,
                                     @"media" : @"music"};
            
            
            ItunesSearch* iTunesSearch = [[ItunesSearch alloc] init];
            [iTunesSearch performApiCallForMethod:@"search"
                                         useCache:YES
                                       withParams:params
                                       andFilters:nil
                                   successHandler:^(NSArray* resultHandler)
             {
                 itemCell.processing = NO;
                 NSLogExt(@"itunes array: %@", resultHandler);
                 if (resultHandler.count == 0)
                 {
                     [NSObject showErrorMessage:@"Track not found"];
                 }
                 else
                 {
#if TARGET_IPHONE_SIMULATOR
                     [NSObject showErrorMessage:@"Cannot open iTunes on simulator"];
#else
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[resultHandler firstObject] valueForKey:@"trackViewUrl"]]];
#endif
                 }
             }
                                   failureHandler:^(NSError* error)
             {
                 itemCell.processing = NO;
                 NSLogExt(@"itunes error: %@", error.localizedDescription);
             }];
            break;
        }
        case 4:
        {
            if ([self.feedItem.youtubeLink length])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.feedItem.youtubeLink]];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - ShareHeaderCell delegate
- (BOOL)isFacebookShared:(ShareHeaderCell*)sender
{
    return self.feedItem.facebookShared;
}

- (BOOL)isTwitterShared:(ShareHeaderCell*)sender
{
    return self.feedItem.twitterShared;
}

- (void)shareOnFacebook:(ShareHeaderCell*)sender
        completionBlock:(CompletionBlock)completionBlock
{
    
/*
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *socialSheet = [SLComposeViewController
                                                composeViewControllerForServiceType:SLServiceTypeFacebook];
        [socialSheet setInitialText:[self.feedItem shareText]];
        [socialSheet addURL:[NSURL URLWithString:@"http://botmusic.com/"]];
        
        UIImageView* imageView = [UIImageView new];
//забираем только если закэширована
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.feedItem.trackPicture]
                                                           cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                                       timeoutInterval:0]
                         placeholderImage:nil
                                  success:nil
                                  failure:nil];
        UIImage* image = imageView.image;
        if (!image)
        {
            image = [UIImage imageNamed:@"iTunes-1024"];
        }
        [socialSheet addImage:image];
        self.feedItem.facebookShared = YES;
        
        [self presentViewController:socialSheet animated:YES completion:completionBlock];
    }
    else
    {
        completionBlock();
    }
 
    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:self.feedItem.link]
                                     name:self.feedItem.trackName
                                  caption:nil
                              description:self.feedItem.artist
                                  picture:[NSURL URLWithString:self.feedItem.trackPicture]
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
    {
        if(error) {
            NSLog(@"%@", error.description);
        } else {
            self.feedItem.facebookShared = YES;
            NSLog(@"result %@", results);
        }
        
    }];*/
}

- (void)shareOnTwitter:(ShareHeaderCell*)sender
       completionBlock:(CompletionBlock)completionBlock
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *socialSheet = [SLComposeViewController
                                                composeViewControllerForServiceType:SLServiceTypeTwitter];
        [socialSheet setInitialText:[self.feedItem shareText]];
        [socialSheet addURL:[NSURL URLWithString:@"http://botmusic.com/"]];
        
//забираем только если закэширована
        UIImageView* imageView = [UIImageView new];
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.feedItem.trackPicture]
                                                           cachePolicy:NSURLRequestReturnCacheDataDontLoad
                                                       timeoutInterval:0]
                         placeholderImage:nil
                                  success:nil
                                  failure:nil];
        UIImage* image = imageView.image;
        if (!image)
        {
            image = [UIImage imageNamed:@"iTunes-1024"];
        }
        [socialSheet addImage:image];
        self.feedItem.twitterShared = YES;
        
        [self presentViewController:socialSheet animated:YES completion:completionBlock];
    }
    else
    {
        completionBlock();
    }
};

- (IBAction)closeTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
