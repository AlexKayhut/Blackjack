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
        
        if (self.game.currentPlayer == player || player.isPlaying == NO) {
            label.text = card.contents;
        } else {
            label.text = card.isFaceUp ? card.contents : @" -- ";
        }
        
        [stackView addArrangedSubview:label];
    }
}

// MARK: - BlackjackGameDelegate

- (void)updateUIForState:(State)state {
    switch (state) {
        case AWAITING_DEALER: {
            [self addCardViewsTo:self.dealerCardsStackView fromPlayer:self.game.dealer];
            break;
        }
            
        case COLLECT_BETS: {
            self.betSegmentedControl.selectedSegmentIndex = 0;
            break;
        }
            
        default: break;
    }
    self.dealerChipsLabel.text = [NSString stringWithFormat:@"%ld 💰", (long)self.game.dealer.chips];
    self.playingOptionsMainLabel.text = [NSString stringWithFormat:@"%@ turn:", self.game.currentPlayer.name];
    [self.tableView reloadData]; // Need to refresh every cell since I keep track of backgrouncolor for different states.
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
        cell.backgroundColor = UIColor.whiteColor;
        [cell updateTextColorTo:UIColor.blackColor];
    } else {
        [cell updateTextColorTo:UIColor.whiteColor];
    }
    
    if (!player.isPlaying) {
        if (player.cardsEvaluation == BlackjackGame.cardsAmountToWin) {
            cell.backgroundColor = UIColor.greenColor;
        } else {
            cell.backgroundColor = UIColor.redColor;
        }
        [cell updateTextColorTo:UIColor.blackColor];
    }
    
    cell.name.text = player.name;
    cell.chips.text = [NSString stringWithFormat:@"%lu 💰", (unsigned long)player.chips];
    cell.currentBet.text = [NSString stringWithFormat:@"bet: %lu 🎰", (unsigned long)player.betAmount];
    
    if (self.game.currentPlayer == player || player.isPlaying == NO || self.game.gameState == GAMEOVER) {
        cell.cardEvaluationLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.game evaluateCardsFor:player]];
    } else {
        cell.cardEvaluationLabel.text = @"-";
    }
    
    [self addCardViewsTo:cell.cardsStackView fromPlayer:player];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.game.players.count;
}

@end
