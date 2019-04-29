//
//  ImportArtistsViewController.h
//  botmusic
//

#import <UIKit/UIKit.h>

typedef enum {
    MFImportSourceMusicLibrary
} MFImportSource;

@interface ImportArtistsViewController : AbstractViewController

@property (nonatomic, weak) IBOutlet UITableView *artistsTableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, assign) MFImportSource importSource;

- (IBAction)didTouchUpBackButton:(id)sender;

@end
