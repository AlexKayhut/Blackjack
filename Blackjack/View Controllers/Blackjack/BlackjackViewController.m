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

- (void)viewDidLoad {
  [super viewDidLoad];
  self.game = [[BlackjackGame alloc] initWithDeck:[PlayingCardDeck new]
                                  numberOfPlayers:self.numberOfPlayers
                                         delegate:self];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.decisionSegmentedControl.hidden = YES;
  
  [self.game startGame];
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

- (void)updateUIForState:(State)state {
  NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];
  
//  switch (state) {
//    case COLLECT_BETS: {
//      self.betSegmentedControl.selectedSegmentIndex = 0;
//      NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:[self.game.players indexOfObject:self.game.currentPlayer]];
//      [indexPaths addObject:indexPath];
//      break;
//    }
//
//    case DEAL_CARDS: {
//      [self addCardViewsTo:self.dealerCardsStackView fromPlayer:self.game.dealer];
//      NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:[self.game.players indexOfObject:self.game.currentPlayer]];
//      [indexPaths addObject:indexPath];
//      break;
//    }
//
//    case AWAITING_PLAYERS_DECISION: {
//      NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:[self.game.players indexOfObject:self.game.currentPlayer]];
//      [indexPaths addObject:indexPath];
//    }
//
//    case AWAITING_DEALER: {
//      [self addCardViewsTo:self.dealerCardsStackView fromPlayer:self.game.dealer];
//        [self.tableView reloadData];
//      }
//    }
//
  
  [self addCardViewsTo:self.dealerCardsStackView fromPlayer:self.game.dealer];
//  NSInteger currentPlayerIndex = [self.game.players indexOfObject:self.game.currentPlayer];
//  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPlayerIndex inSection:0];
//  [indexPaths addObject:indexPath];
//
//  if (currentPlayerIndex - 1 >= 0) {
//    [indexPaths addObject:[NSIndexPath indexPathForRow:(currentPlayerIndex - 1) inSection:0]];
//  }
  self.dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)self.game.dealer.chips];
  self.playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", self.game.currentPlayer.name];
 
//  [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation: UITableViewRowAnimationAutomatic];
  [self.tableView reloadData];
}

- (void)betsOver {
  self.betSegmentedControl.hidden = YES;
  self.decisionSegmentedControl.hidden = NO;
}

// MARK: - IBActions

- (IBAction)betSegmentedControlValueChanged:(UISegmentedControl *)sender {
  NSString *selectedSegmentTitle = [self.betSegmentedControl
                                    titleForSegmentAtIndex:self.betSegmentedControl.selectedSegmentIndex];
  if ([selectedSegmentTitle isEqualToString: @"-"]) {
    return;
  }
  [self.game setBet:selectedSegmentTitle.integerValue];
  self.betSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)decisionSegmentedControlValueChanged:(UISegmentedControl *)sender {
  NSString *selectedSegmentTitle = [self.decisionSegmentedControl
                                    titleForSegmentAtIndex:self.decisionSegmentedControl.selectedSegmentIndex];
  if ([selectedSegmentTitle isEqualToString: @"-"]) {
    return;
  }
  
  [self.game setDecision:(self.decisionSegmentedControl.selectedSegmentIndex-1)];
  self.decisionSegmentedControl.selectedSegmentIndex = 0;
}

// MARK: Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  NSString *cellIdentifier = PlayerCellTableViewCell.identifier;
  PlayerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                  forIndexPath:indexPath];
  Player *player = self.game.players[indexPath.row];
  
  if (indexPath.row == [self.game.players indexOfObject:self.game.currentPlayer]) {
    cell.backgroundColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
  }
  
  if (!player.isPlaying) {
    if (player.cardsEvaluation == BlackjackGame.cardsAmountToWin) {
      cell.backgroundColor = UIColor.greenColor;
    } else {
      cell.backgroundColor = UIColor.redColor;
    }
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
