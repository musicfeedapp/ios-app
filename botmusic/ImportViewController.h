//
//  ImportViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>

@interface ImportViewController : AbstractViewController

@property (nonatomic, weak) IBOutlet UITableView *importSourcesTableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

- (IBAction)didTouchUpBackButton:(id)sender;

@end
