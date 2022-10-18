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
    if (!_game)
        _game = [[BlackjackGame alloc] initWithDeck: [PlayingCardDeck new]];
    return _game;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.game.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.decisionSegmentedControl.hidden = YES;
    
    [self.game startGame: self.numberOfPlayers];
}

-(void)addCardViewsTo:(UIStackView *)stackView fromPlayer:(Contestant *)player {
    for (UIView *cardView in stackView.arrangedSubviews) {
        [cardView removeFromSuperview];
    }
    
    for (Card *card in player.cards) {
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentRight;
        label.text = card.isFaceUp ? card.contents : @" -- ";
        [stackView addArrangedSubview:label];
    }
}

// MARK: - BlackjackGameDelegate

- (void)updateUI {
    [self addCardViewsTo: self.dealerCardsStackView fromPlayer: self.game.dealer];
    self.dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)self.game.dealer.chips];
    self.playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", self.game.currentPlayer.name];
    self.betSegmentedControl.selectedSegmentIndex = 0;
    [self.tableView reloadData];
}

- (void)betsOver {
    self.betSegmentedControl.hidden = YES;
    self.decisionSegmentedControl.hidden = NO;
}

// MARK: - IBActions

- (IBAction)betSegmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *selectedSegmentTitle = [self.betSegmentedControl titleForSegmentAtIndex:self.betSegmentedControl.selectedSegmentIndex];
    if ([selectedSegmentTitle isEqualToString: @"-"]) {
        return;
    }
    [self.game setBet:selectedSegmentTitle.integerValue];
    self.betSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)decisionSegmentedControlValueChanged:(UISegmentedControl *)sender {
    NSString *selectedSegmentTitle = [self.decisionSegmentedControl titleForSegmentAtIndex:self.decisionSegmentedControl.selectedSegmentIndex];
    if ([selectedSegmentTitle isEqualToString: @"-"]) {
        return;
    }
    
    [self.game setDecision:(enum Decision) (self.decisionSegmentedControl.selectedSegmentIndex-1)];
    self.decisionSegmentedControl.selectedSegmentIndex = 0;
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
