//
//  MFOnBoardingSuggestionsSearchTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 8/26/15.
//
//

#import <UIKit/UIKit.h>

@interface MFOnBoardingSuggestionsSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeight;

@end
