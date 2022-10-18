//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "PlayingCard.h"

typedef NS_ENUM(NSInteger, State) {
    COLLECT_BETS, DEAL_CARDS, AWAITING_PLAYERS_DECISION, AWAITING_DEALER
};

// MARK: - Private Properties

@interface BlackjackGame ()

@property (nonatomic, strong) Deck *deck;
@property (nonatomic) NSInteger cardsAmountToWin;
@property (nonatomic) NSInteger dealerMinimumCardEvaluation;
@property (nonatomic, assign) State gameState;
@property (nonatomic) NSArray *gameStates;

@end

// MARK: - Implementation

@implementation BlackjackGame

@synthesize dealer = _dealer; // because we provide setter AND getter

- (Contestant *) dealer {
    if (!_dealer)
        _dealer = [[Contestant alloc] initWith:@"Dealer" cards:[NSMutableArray new] chips: 0 isPlaying:YES];
    return _dealer;
}

// MARK: - Static Methods

+ (NSDictionary<NSString*, NSNumber*> *)cardValues {
    return @{@"2": @2, @"3": @3, @"4": @4, @"5": @5, @"6": @6, @"7": @7, @"8": @8, @"9": @9, @"10": @10, @"J": @10, @"Q": @10, @"K": @10};
}

+ (NSInteger)cardsAmountToWin {
    return 21;
}

+ (NSInteger)dealerMinimumCardEvaluation {
    return 16;
}

- (NSArray *)currentActivePlayers {
    NSMutableArray *activePlayers = [NSMutableArray new];
    for (Player *player in self.players) {
        if (player.isPlaying) {
            [activePlayers addObject:player];
        }
    }
    return activePlayers;
}

// MARK: - Init

- (instancetype)initWithDeck:(Deck *)deck {
    self = [super init];
    if (self) {
        _deck = deck;
    }
    return self;
}

// MARK: - Game Logic

-(void)setupContestants:(NSInteger) numberOfPlayers {
    NSMutableArray *newPlayers = [NSMutableArray arrayWithCapacity:numberOfPlayers];
    
    for (int i=0; i<numberOfPlayers; i++) {
        NSString *name = [NSString stringWithFormat:@"Player #%d", i+1];
        Player *player = [[Player alloc] initWith:name cards:[NSMutableArray new] chips: 50 isPlaying:YES];
        [newPlayers addObject: player];
    }
    self.players = newPlayers;
    self.currentPlayer = self.players.firstObject;
}

- (void)setDecision:(Decision)decision {
    switch (decision) {
        case HIT: {
            [self.currentPlayer.cards addObject:[self.deck drawRandomCard:YES]];
            NSInteger cardsEvaluation = [self evaluateCardsFor:_currentPlayer];
            [self handlePlayersLogicBasedOn: cardsEvaluation forPlayer: self.currentPlayer];
            
            if (!self.currentPlayer.isPlaying) {
                [self nextPlayer];
            }
            break;
        }
        case STAND:
            [self nextPlayer];
            break;
            
        case SURRENDER: {
            self.dealer.chips += self.currentPlayer.betAmount;
            self.currentPlayer.betAmount = 0;
            self.currentPlayer.isPlaying = NO;
            [self nextPlayer];
            break;
        }
    }
    [self.delegate updateUI];
}

- (void)setBet:(NSInteger)amount {
    if (self.currentPlayer.chips >= amount) {
        self.currentPlayer.betAmount += amount;
        self.currentPlayer.chips -= amount;
        [self nextPlayer];
        [self.delegate updateUI];
    }
}

-(void)nextPlayer {
    NSArray *currentActivePlayers = [self currentActivePlayers];

    if (currentActivePlayers.count == 0) {
        [self gameOver];
        return;
    }
    NSInteger index = [self.players indexOfObject: self.currentPlayer];

    if (index < self.players.count - 1) {
        self.currentPlayer = self.players[index + 1];
    } else if (index == self.players.count - 1) {
        
        [self progressGameState];
    } else {
        // TODO: handle case
    }
}

// TODO : encapuslate some logic
-(void)progressGameState {
    switch (self.gameState) {
        case COLLECT_BETS:
            self.gameState = DEAL_CARDS;
        
        case DEAL_CARDS: {
            [self.delegate betsOver];
            [self dealCardsWithDealerFaceUp:YES];
            [self dealCardsWithDealerFaceUp:NO];
            [self evaluateCards];
            [self.delegate updateUI];
            self.currentPlayer = self.players.firstObject;
            self.gameState = AWAITING_PLAYERS_DECISION;
            break;
        }
            
        case AWAITING_PLAYERS_DECISION:
            self.gameState = AWAITING_DEALER;
            
        case AWAITING_DEALER: {
            [self.dealer.cards.lastObject setIsFaceUp:YES];
            NSInteger dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
            while (dealerCardsEvaluation <= [BlackjackGame dealerMinimumCardEvaluation]) {
                [self.dealer.cards addObject:[self.deck drawRandomCard:YES]];
                dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
            }
            [self.delegate updateUI];
            
            for (Player *activePlayer in [self currentActivePlayers]) {
                if (activePlayer.cardsEvaluation > self.dealer.cardsEvaluation || self.dealer.cardsEvaluation > [BlackjackGame cardsAmountToWin]) {
                    activePlayer.chips += activePlayer.betAmount * 2;
                } else {
                    self.dealer.chips += activePlayer.betAmount;
                    activePlayer.isPlaying = NO;
                }
                activePlayer.betAmount = 0;
                
            }
            
            [self gameOver];
            break;
        }
    }
}

-(void)dealCardsWithDealerFaceUp:(BOOL)isDealerCardFaceUp {
    for (Player *player in self.players) {
        [player.cards addObject: [self.deck drawRandomCard:YES]];
    }
    [self.dealer.cards addObject:[self.deck drawRandomCard:isDealerCardFaceUp]];
}

-(void)handlePlayersLogicBasedOn: (NSInteger)cardsEvaluation forPlayer:(Player *)player {
    if (cardsEvaluation == [BlackjackGame cardsAmountToWin]) {
        player.isPlaying = NO;
        player.chips = player.betAmount * 1.5;
        player.betAmount = 0;
    } else if (cardsEvaluation > [BlackjackGame cardsAmountToWin]) {
        player.isPlaying = NO;
        player.chips -= player.betAmount;
        self.dealer.chips += player.betAmount;
        player.betAmount = 0;
    }
}

-(void)evaluateCards {
    for (Player *player in self.players) {
        NSInteger cardsEvaluation = [self evaluateCardsFor:player];
        [self handlePlayersLogicBasedOn:cardsEvaluation forPlayer:player];
    }
}

-(NSInteger)evaluateCardsFor: (Contestant *)contestant {
    NSInteger sum = 0;
    NSInteger aceCount = 0;
    
    for (PlayingCard *value in contestant.cards) {
        if ([value.cardValue  isEqual: @"A"]) {
            aceCount += 1;
            continue;
        }
        sum += [BlackjackGame cardValues][value.cardValue].integerValue;
    }
    
    for (int i=0; i<aceCount;i++) {
        if ((sum + 11) <= 21) {
            sum += 11;
        } else if ((sum + 1) <= 21) {
            sum += 1;
        }
    }
    contestant.cardsEvaluation = sum;
    return sum;
}

@end

@implementation BlackjackGame (Game)

// MARK: - Game Methods

- (void)startGame:(NSInteger)numberOfPlayers {
    [self setupContestants:numberOfPlayers];
    self.gameState = COLLECT_BETS;
    [self.delegate updateUI];
}

- (void)gameOver {
//    [_dealer.cards removeAllObjects];
}

@end
