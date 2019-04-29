//
//  MFProfilePartViewController.h
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache_FadeIn.h"
#import "MFNotificationManager.h"
#import "UIColor+Expanded.h"

@class MFProfilePartViewController;
@protocol MFProfilePartViewControllerDelegate <NSObject>

- (void) profilePartViewControllerDidTapAtHeader:(MFProfilePartViewController*)controller;
- (void) profilePartViewControllerDidTapAtMore:(MFProfilePartViewController*)controller;
- (void) profilePartViewController:(MFProfilePartViewController*)controller didSelectItem:(id)object;
- (void) profilePartViewControllerLoadedObjects:(MFProfilePartViewController *)controller;
@end

@interface MFProfilePartViewController : UIViewController
@property id<MFProfilePartViewControllerDelegate> delegate;
- (void) applyClosedState;
- (void) applyOpenedState;
- (void) reloadData;
@property (nonatomic) BOOL isLoadedObjects;
@property (nonatomic, strong) NSArray* objects;
@property (nonatomic, strong) MFUserInfo* userInfo;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic) BOOL isOpenedState;
@end
