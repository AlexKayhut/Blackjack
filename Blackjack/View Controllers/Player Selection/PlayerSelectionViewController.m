//
//  PlayerSelectionViewController.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "PlayerSelectionViewController.h"
#import "BlackjackViewController.h"

@interface PlayerSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerSelectionView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numOfPlayersSegmentedControl;

@end

@implementation PlayerSelectionViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSInteger index = [self.numOfPlayersSegmentedControl selectedSegmentIndex];
    NSString *numberOfPlayers = [self.numOfPlayersSegmentedControl titleForSegmentAtIndex:index];
    BlackjackViewController *viewController = segue.destinationViewController;
    viewController.numberOfPlayers = numberOfPlayers.integerValue;
}

@end

