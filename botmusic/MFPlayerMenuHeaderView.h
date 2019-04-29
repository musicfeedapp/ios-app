//
//  MFPlayerMenuHeaderView.h
//  botmusic
//
//  Created by Panda Systems on 11/24/15.
//
//

#import <UIKit/UIKit.h>

@interface MFPlayerMenuHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;
@property (nonatomic) BOOL isShuffleButtonSetUp;

@end
