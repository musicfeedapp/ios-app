//
//  MFAddProfileInfoViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>

typedef void(^MFAddInfoCompletionBlock)(BOOL added, NSString* info);

@interface MFAddProfileInfoViewController : UIViewController
@property(nonatomic, strong) NSString* infoToEdit;
@property(nonatomic, strong) NSString* headerTitle;
@property(nonatomic, strong) NSString* textFieldPlaceholder;
-(void)setCompletionBlock:(MFAddInfoCompletionBlock)completionBlock;
@end
