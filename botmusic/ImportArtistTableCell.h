//
//  ImportArtistTableCell.h
//  botmusic
//

#import <UIKit/UIKit.h>

@interface ImportArtistTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *artistImageView;
@property (nonatomic, weak) IBOutlet UILabel *artistNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *checkBoxButton;

- (IBAction)didTouchUpCheckBoxButton:(id)sender;

@end
