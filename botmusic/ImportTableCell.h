//
//  ImportTableCell.h
//  botmusic
//

#import <UIKit/UIKit.h>

@interface ImportTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *scanLabel;
@property (nonatomic, weak) IBOutlet UILabel *rigthArrowLabel;
@property (nonatomic, weak) IBOutlet UIView *separatorView;

@end
