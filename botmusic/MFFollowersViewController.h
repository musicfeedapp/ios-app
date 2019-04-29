//
//  MFFollowersViewController.h
//  botmusic
//
//  Created by Panda Systems on 2/9/15.
//
//

#import <UIKit/UIKit.h>
#import "MFScrollingChildDelegate.h"

@interface MFFollowersViewController : AbstractViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage* headerImage;
@property (nonatomic, strong) MFUserInfo* userInfo;
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic) BOOL shouldJustDisplayGivenFollowItems;
@property (nonatomic) int numberOfTotalFollowers;
@property (nonatomic) BOOL isMyFollowItems;

@end
