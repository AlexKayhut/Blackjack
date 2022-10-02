//
//  BlackjackViewController.m
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "BlackjackViewController.h"
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

- (BlackjackGame *)game {
    if (!_game) _game = [[BlackjackGame alloc] initWith: [[PlayingCardDeck alloc] init] ];
    return _game;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.game.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _decisionSegmentedControl.hidden = YES;
    
    [self.game startGame:_numberOfPlayers];
}

-(void)addCardViewsTo:(UIStackView *)stackView fromPlayer:(Contestant *)player {
    for (UIView *cardView in stackView.arrangedSubviews) {
        [cardView removeFromSuperview];
    }
    
    for (Card *card in player.cards) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentRight;
        label.text = card.isFaceUp ? card.contents : @" -- ";
        [stackView addArrangedSubview:label];
    }
}

// MARK: - BlackjackGameDelegate

- (void)updateUI {
    [self addCardViewsTo:_dealerCardsStackView fromPlayer: self.game.dealer];
    _dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)self.game.dealer.chips];
    _playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", self.game.currentPlayer.name];
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
    [self.game setBet:selectedSegmentTitle.integerValue];
    _betSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)decisionSegmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *selectedSegmentTitle = [_decisionSegmentedControl titleForSegmentAtIndex:_decisionSegmentedControl.selectedSegmentIndex];
    if ([selectedSegmentTitle isEqualToString: @"-"]) {
        return;
    }
    
    [self.game setDecision:(enum Decision) (_decisionSegmentedControl.selectedSegmentIndex-1)];
    _decisionSegmentedControl.selectedSegmentIndex = 0;
}

// MARK: Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PlayerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCellTableViewCell" forIndexPath:indexPath];
    Player *player = self.game.players[indexPath.row];
    
    if (indexPath.row == [self.game.players indexOfObject:self.game.currentPlayer]) {
        cell.backgroundColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
    
    if (!player.isPlaying) {
        cell.backgroundColor = player.cardsEvaluation == [BlackjackGame cardsAmountToWin] ? UIColor.greenColor : UIColor.redColor;
    }
    
    cell.name.text = player.name;
    cell.chips.text = [NSString stringWithFormat:@"%lu 💰", (unsigned long)player.chips];
    cell.currentBet.text = [NSString stringWithFormat:@"bet: %lu 🎰", (unsigned long)player.betAmount];
    
    [self addCardViewsTo:cell.cardsStackView fromPlayer:player];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.game.players.count;
}

@end
