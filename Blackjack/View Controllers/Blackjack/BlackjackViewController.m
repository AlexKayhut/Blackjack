//
//  BlackjackViewController.m
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "BlackjackViewController.h"
#import "PlayerCellTableViewCell.h"

@interface BlackjackViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *betSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *decisionSegmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStackView *dealerCardsStackView;
@property (weak, nonatomic) IBOutlet UILabel *dealerChipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *playingOptionsMainLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *dealerEvaluationLabel;
@property (nonatomic, strong) BlackjackGame *game;

@end

@implementation BlackjackViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.game = [[BlackjackGame alloc] initWithNumberOfPlayers:self.numberOfPlayers delegate:self];
  [self resetUI];
}

- (void)resetUI {
  self.betSegmentedControl.hidden = NO;
  self.decisionSegmentedControl.hidden = YES;
  self.actionButton.hidden = YES;
  self.dealerEvaluationLabel.text = @"0";
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

- (void)updateUIForDealer {
  //  self.dealerEvaluationLabel.text = [NSString stringWithFormat:@"%ld", (long)self.game.dealer.cardsEvaluation];
  [self addCardViewsTo:self.dealerCardsStackView fromPlayer:self.game.dealer];
  self.dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)self.game.dealer.chips];
}

- (void)updateUIForPlayerAtIndex:(NSArray<NSNumber *>*)array {
  NSMutableArray<NSIndexPath *> *indexPaths = [[NSMutableArray alloc]initWithCapacity: array.count];
  for (NSNumber *number in array) {
    [indexPaths addObject:[NSIndexPath indexPathForRow: number.integerValue inSection:0]];
  }
  [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)focusOnPlayerAtIndex: (NSInteger) index {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:true];
}

- (void)betsOver {
  self.betSegmentedControl.hidden = YES;
  self.decisionSegmentedControl.hidden = NO;
}

- (void)roundOver {
  self.actionButton.hidden = NO;
  self.decisionSegmentedControl.hidden = YES;
  [self.actionButton setTitle:@"Next Round" forState:UIControlStateNormal];
}

- (void)gameOver {
  self.actionButton.hidden = YES;
  self.decisionSegmentedControl.hidden = YES;
}

// MARK: - IBActions

- (IBAction)betSegmentedControlValueChanged:(UISegmentedControl *)sender {
  NSString *selectedSegmentTitle = [self.betSegmentedControl
                                    titleForSegmentAtIndex:self.betSegmentedControl.selectedSegmentIndex];
  if ([selectedSegmentTitle isEqualToString: @"-"]) {
    return;
  }
  [self.game collectBet:selectedSegmentTitle.integerValue];
  self.betSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)decisionSegmentedControlValueChanged:(UISegmentedControl *)sender {
  NSString *selectedSegmentTitle = [self.decisionSegmentedControl
                                    titleForSegmentAtIndex:self.decisionSegmentedControl.selectedSegmentIndex];
  if ([selectedSegmentTitle isEqualToString: @"-"]) {
    return;
  }
  
  [self.game collectDecision:(self.decisionSegmentedControl.selectedSegmentIndex-1)];
  self.decisionSegmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)actionButtonDidTap:(UIButton *)sender {
  [self.game prepareForNewRound];
  [self resetUI];
}

// MARK: Table View

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
  NSString *cellIdentifier = PlayerCellTableViewCell.identifier;
  PlayerCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  Player *player = self.game.players[indexPath.row];
  
  if (indexPath.row == [self.game.players indexOfObject:self.game.currentPlayer]) {
    cell.backgroundColor = UIColor.whiteColor;
    self.playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", player.name];
  }
  
  if (player.state == GOT_BLACKJACK) {
    cell.backgroundColor = UIColor.greenColor;
  } else if (player.state == BUST) {
    cell.backgroundColor = UIColor.redColor;
  }
  
  cell.name.text = player.name;
  cell.chips.text = [NSString stringWithFormat:@"%lu 💰", (unsigned long)player.chips];
  cell.currentBet.text = [NSString stringWithFormat:@"bet: %lu", (unsigned long)[self.game getBetAmountForPlayer:player]];
  
  //    if (self.game.currentPlayer == player || player.state != PLAYING || self.game.gameState == GAMEOVER) {
  cell.cardEvaluationLabel.text = [NSString stringWithFormat:@"%ld", (long)player.cardsEvaluation];
  //    } else {
  //        cell.cardEvaluationLabel.text = @"-";
  //    }
  
  [self addCardViewsTo:cell.cardsStackView fromPlayer:player];
  return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.game.players.count;
}

@end
