//
//  MFEmailTableViewCell.h
//  botmusic
//
//  Created by Panda Systems on 9/11/15.
//
//

#import <UIKit/UIKit.h>

@interface MFEmailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;

@end
