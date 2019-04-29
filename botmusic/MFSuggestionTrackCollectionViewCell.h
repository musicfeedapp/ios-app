//
//  MFSuggestionTrackCollectionViewCell.h
//  botmusic
//
//  Created by Vladimir on 27.11.15.
//
//

#import <UIKit/UIKit.h>
#import "MFPlayerAnimationView.h"

@interface MFSuggestionTrackCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *trackImage;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *smallPlayButton;
@property (nonatomic, strong) MFTrackItem *track;
@property (weak, nonatomic) IBOutlet UIView *playerIndicatorContainer;
@property (strong, nonatomic) MFPlayerAnimationView* playerIndicator;
@end
