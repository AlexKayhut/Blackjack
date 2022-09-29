//
//  BlackjackViewController.m
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "BlackjackViewController.h"
#import "BlackjackGame.h"
#import "Player.h"
#import "PlayingCardDeck.h"
#import "PlayerCellTableViewCell.h"

@interface BlackjackViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *betSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *decisionSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStackView *dealerCardsStackView;
@property (weak, nonatomic) IBOutlet UILabel *dealerChipsLabel;
@property (weak, nonatomic) IBOutlet UIStackView *playingOptionsStackView;
@property (weak, nonatomic) IBOutlet UILabel *playingOptionsMainLabel;

@property (nonatomic) BlackjackGame *game;
@end

@implementation BlackjackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _game = [[BlackjackGame alloc] initWith: [[PlayingCardDeck alloc] init] ];
    _game.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _decisionSegmentedControl.hidden = YES;
    [_game startGame:_numberOfPlayers];
    [self updateUI];
}

-(void)addCardViewsTo:(UIStackView *)stackView fromPlayer:(Contestant *)player {
    for (UIView *cardView in stackView.arrangedSubviews) {
        [cardView removeFromSuperview];
    }
    
    for (Card *card in player.cards) {
        UILabel *label = [[UILabel alloc] init];
        label.text = card.isFaceUp ? card.contents : @"--";
        [stackView addArrangedSubview:label];
    }
}

// MARK: - BlackjackGameDelegate

- (void)updateUI {
    [self addCardViewsTo:_dealerCardsStackView fromPlayer: _game.dealer];
    _dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)_game.dealer.chips];
    _playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", _game.currentPlayer.name];
    _betSegmentedControl.selectedSegmentIndex = 0;
    [_tableView reloadData];
}

- (void)betsOver {
    _betSegmentedControl.hidden = YES;
    _decisionSegmentedControl.hidden = NO;
}

// MARK: - IBActions

- (IBAction)betSegmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *selectedSegmentTitle = [_betSegmentedControl titleForSegmentAtIndex:_betSegmentedControl.selectedSegmentIndex];
    if ([selectedSegmentTitle isEqualToString: @"-"]) {
        return;
    }
    [_game setBet:selectedSegmentTitle.integerValue];
    _betSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)decisionSegmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *selectedSegmentTitle = [_decisionSegmentedControl titleForSegmentAtIndex:_decisionSegmentedControl.selectedSegmentIndex];
    if ([selectedSegmentTitle isEqualToString: @"-"]) {
        return;
    }
    
    [_game setDecision:(enum Decision) (_decisionSegmentedControl.selectedSegmentIndex-1)];
    _decisionSegmentedControl.selectedSegmentIndex = 0;
}

// MARK: Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlayerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCellTableViewCell" forIndexPath:indexPath];
    Player *player = _game.players[indexPath.row];
    
    if (player.decision == (enum Decision) surrender) {
        // Remove user?
    }
    
    if (indexPath.row == [_game.players indexOfObject:_game.currentPlayer]) {
        cell.backgroundColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    
    cell.name.text = player.name;
    cell.chips.text = [NSString stringWithFormat:@"%lu 💰", (unsigned long)player.chips];
    cell.currentBet.text = [NSString stringWithFormat:@"🎰%lu", (unsigned long)player.betAmount];
    
    [self addCardViewsTo:cell.cardsStackView fromPlayer:player];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _game.players.count;
}

@end
