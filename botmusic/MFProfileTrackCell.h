//
//  MFProfileTrackCell.h
//  botmusic
//
//  Created by Panda Systems on 1/12/16.
//
//

#import <UIKit/UIKit.h>
#import "MFPlayerAnimationView.h"
@class MFProfileTrackCell;

@protocol MFProfileTrackCellDelegate <NSObject>

-(void)profileTrackCellDidTapPlay:(MFProfileTrackCell*)cell;

@end

@interface MFProfileTrackCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *trackImage;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayButton;
@property (nonatomic, strong) MFTrackItem *track;
@property (weak, nonatomic) IBOutlet UIView *playerIndicatorContainer;
@property (strong, nonatomic) MFPlayerAnimationView* playerIndicator;
@property id<MFProfileTrackCellDelegate> delegate;
@end
