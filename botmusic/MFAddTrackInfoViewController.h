//
//  MFAddTrackInfoViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>

@protocol MFAddTrackInfoViewControllerDelegate <NSObject>

-(void)didSelectAddTrack:(MFTrackItem*)track;
-(void)didSelectShareTrack:(MFTrackItem*)track;

@end

@interface MFAddTrackInfoViewController : UIViewController
@property (nonatomic, strong) MFTrackItem* trackItem;
@property (nonatomic, weak) id<MFAddTrackInfoViewControllerDelegate> delegate;
@property (nonatomic) int controllerNumber;
@end
