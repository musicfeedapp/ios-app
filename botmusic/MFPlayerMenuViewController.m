//
//  MFPlayerMenuViewController.m
//  botmusic
//
//  Created by Panda Systems on 11/19/15.
//
//

#import "MFPlayerMenuViewController.h"
#import "PlaylistTrackCell.h"
#import "MFPlayerMenuHeaderView.h"

typedef enum : NSUInteger {
    MFPlayerMenuStateHistory,
    MFPlayerMenuStateQueue,
} MFPlayerMenuState;

@interface MFPlayerMenuViewController () <PlaylistTrackCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UIButton *anotherScreenButton;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) MFPlayerMenuState menuState;
@property (weak, nonatomic) IBOutlet UITableView *queueTableView;
@property (weak, nonatomic) IBOutlet UIView *historyView;
@property (nonatomic, strong) NSArray* historyTracks;
@property (nonatomic, strong) NSArray* queueTracks;
@property (weak, nonatomic) IBOutlet UIView *queueView;
@property (nonatomic, strong) NSLayoutConstraint* progressViewWidth;
@end

@implementation MFPlayerMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *playlistTrackCellNib = [UINib nibWithNibName:@"PlaylistTrackCell" bundle:nil];
    [self.historyTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    [self.queueTableView registerNib:playlistTrackCellNib forCellReuseIdentifier:@"PlaylistTrackCell"];
    [self.queueTableView registerNib:[UINib nibWithNibName:@"MFPlayerMenuHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"MFPlayerMenuHeaderView"];
    [self.queueTableView setEditing:YES animated:NO];
    // Do any additional setup after loading the view.
    self.historyTracks = [NSArray array];
    self.queueTracks = [NSArray array];
    [self updateTracks];
    [self changeMenuState:MFPlayerMenuStateQueue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTracks) name:@"MFUpdateTrackHistory" object:nil];
    
}

- (void)changeMenuState:(MFPlayerMenuState)state{
    self.menuState = state;
    switch (state) {
        case MFPlayerMenuStateHistory:
            self.historyView.hidden = NO;
            self.queueView.hidden = YES;
            self.headerLabel.text = NSLocalizedString(@"History", nil);
            [self.anotherScreenButton setTitle:NSLocalizedString(@"Play Queue", nil) forState:UIControlStateNormal];
            break;
        case MFPlayerMenuStateQueue:
            self.historyView.hidden = YES;
            self.queueView  .hidden = NO;
            self.headerLabel.text = NSLocalizedString(@"Play Queue", nil);
            [self.anotherScreenButton setTitle:NSLocalizedString(@"History", nil) forState:UIControlStateNormal];
            break;

        default:
            break;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneTapped:(id)sender {
    [self.delegate playerMenuViewControllerDidSelectDone:self];
}

- (void) updateTracks{
    int numberOfTracks = 100;
    [dataManager getLastPlayedTracks:numberOfTracks completion:^(NSArray *array) {
        NSArray* previousTracks = self.historyTracks;
        self.historyTracks = array;
        if (_historyTracks.count == [_historyTableView numberOfRowsInSection:0]  && _historyTracks.count > 0) {
            if ([previousTracks containsObject:_historyTracks[0]]) {

                NSIndexPath* oldIP = [NSIndexPath indexPathForItem:[previousTracks indexOfObject:_historyTracks[0]] inSection:0];
                NSIndexPath* newIP = [NSIndexPath indexPathForItem:0 inSection:0];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [self.historyTableView reloadData];
                }];
                [self.historyTableView beginUpdates];

                [self.historyTableView moveRowAtIndexPath:oldIP toIndexPath:newIP];

                [self.historyTableView endUpdates];
                [CATransaction commit];

            } else {

                NSIndexPath* oldIP = [NSIndexPath indexPathForItem:numberOfTracks-1 inSection:0];
                NSIndexPath* newIP = [NSIndexPath indexPathForItem:0 inSection:0];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [self.historyTableView reloadData];
                }];
                [self.historyTableView beginUpdates];

                [self.historyTableView deleteRowsAtIndexPaths:@[oldIP] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.historyTableView insertRowsAtIndexPaths:@[newIP] withRowAnimation:UITableViewRowAnimationAutomatic];

                [self.historyTableView endUpdates];
                [CATransaction commit];

            }

        } else if (_historyTracks.count == [_historyTableView numberOfRowsInSection:0] +1 && _historyTracks.count > 0){

            NSIndexPath* newIP = [NSIndexPath indexPathForItem:0 inSection:0];
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self.historyTableView reloadData];
            }];
            [self.historyTableView beginUpdates];

            [self.historyTableView insertRowsAtIndexPaths:@[newIP] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.historyTableView endUpdates];
            [CATransaction commit];

        } else {
            [self.historyTableView reloadData];
        }

    }];

    self.queueTracks = [playerManager getCurrentQueue];
    [self.queueTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==_queueTableView) {
        return 50;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView==_queueTableView) {
        MFPlayerMenuHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MFPlayerMenuHeaderView"];

        if (section == 0) {
            header.label.text = @"NOW PLAYING";
            header.shuffleButton.hidden = YES;
            return header;
        } else if (section == 1){
            if (playerManager.isPlayingPlaylist) {
                header.label.text = [playerManager.currentSourceName uppercaseString];
            } else {
                header.label.text = @"UP NEXT";
            }
            if (!header.isShuffleButtonSetUp) {
                [header.shuffleButton addTarget:self action:@selector(shuffleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                header.isShuffleButtonSetUp = YES;
            }
            header.shuffleButton.hidden = NO;
            return header;
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView==_historyTableView) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _historyTableView) {
        return self.historyTracks.count;
    } else {
        if (section == 0) {
            return 1;
        } else {
            return self.queueTracks.count - 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellID = @"PlaylistTrackCell";

    PlaylistTrackCell *cell = (PlaylistTrackCell *)[tableView dequeueReusableCellWithIdentifier:cellID];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PlaylistTrackCell" owner:nil options:nil] lastObject];
    }
    //cell.playlistTrackCellDelegate = self;
    cell.hideDefaultArtwork = YES;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == 0) {
        cell.separatorView.hidden = YES;
    } else {
        cell.separatorView.hidden = NO;
    }
    cell.separatorView.alpha = 0.15;
    cell.undoRemoveView.hidden = YES;
    cell.playlistTrackCellDelegate = self;
    cell.showMoreButton.hidden = YES;
    cell.isDarkBackGround = YES;
    if (!cell.additionalBackgroundView) {
        UIVisualEffectView* visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
        cell.additionalBackgroundView = visualEffect;
        CGFloat offset = 1.0/[[UIScreen mainScreen] scale];
        visualEffect.frame = CGRectMake(0, offset, [UIScreen mainScreen].bounds.size.width, 55.0);
        [cell.contentView insertSubview:visualEffect atIndex:0];
        UIView* v = [[UIView alloc] initWithFrame:visualEffect.bounds];
        v.backgroundColor = [UIColor whiteColor];
        v.alpha = 0.2;
        [visualEffect.contentView addSubview:v];
    }
    MFTrackItem* track;
    if (tableView == _historyTableView) {
        cell.tag = 1;
        track = self.historyTracks[indexPath.row];
    } else {
        if (indexPath.section == 0) {
            cell.tag = 2;
            cell.progressView.hidden = NO;
            self.progressViewWidth = cell.progressViewWidth;
            cell.progressViewWidth.constant = [playerManager trackProgress]*[UIScreen mainScreen].bounds.size.width;
            track = [self.queueTracks firstObject];
        } else {
            cell.progressView.hidden = YES;
            cell.tag = 3;
            track = self.queueTracks[indexPath.row + 1];
        }
    }
    [cell setTrack:track];

    return cell;

}

- (void)playlistTrackCell:(PlaylistTrackCell *)cell didTouchThumb:(MFTrackItem *)track{
    if (cell.tag == 1) {
        int index = (int)[self.historyTableView indexPathForCell:cell].row;
        if (![playerManager.currentTrack isEqual:self.historyTracks[index]]) {
            [playerManager playSingleTrack:self.historyTracks[index]];
        }
        else if ([playerManager playing]) {
            [playerManager pauseTrack];
        }
        else {
            [playerManager resumeTrack];
        }
    } else if (cell.tag == 2 || cell.tag == 3){
        NSIndexPath* ip = [self.queueTableView indexPathForCell:cell];
        int index;
        if (ip.section == 0) {
            index = 0;
        } else {
            index = (int)ip.row + 1;
        }
        if (![playerManager.currentTrack isEqual:self.queueTracks[index]]) {
            [playerManager reorderCurrentQueueFromIndex:index];
        }
        else if ([playerManager playing]) {
            [playerManager pauseTrack];
        }
        else {
            [playerManager resumeTrack];
        }
    }
}

- (IBAction)anotherScreenButtonTapped:(id)sender {
    switch (self.menuState) {
        case MFPlayerMenuStateHistory:
            [self changeMenuState:MFPlayerMenuStateQueue];
            break;
        case MFPlayerMenuStateQueue:
            [self changeMenuState:MFPlayerMenuStateHistory];
            break;

        default:
            break;
    }
}
-(void)setCurrentTrackProgress:(CGFloat)progress{
    self.progressViewWidth.constant = progress*self.view.bounds.size.width;
}

-(void)shuffleButtonTapped{
    [playerManager shuffleTracks];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.queueTableView && indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.queueTableView && indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.section == 1) {
        [playerManager moveTrackAtIndex:fromIndexPath.row+1 toIndex:toIndexPath.row+1];
        self.queueTracks = [playerManager getCurrentQueue];
        [self.queueTableView reloadData];
    }
    if(toIndexPath.section == 0 && toIndexPath.row == 1){
        [playerManager moveTrackAtIndex:fromIndexPath.row+1 toIndex:1];
        self.queueTracks = [playerManager getCurrentQueue];
        [self.queueTableView reloadData];
    }
    if(toIndexPath.section == 0 && toIndexPath.row == 0){
        [playerManager reorderCurrentQueueFromIndex:(int)fromIndexPath.row+1];
    }
}

@end
