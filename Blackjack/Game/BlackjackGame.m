//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "Player.h"

// MARK: - Private Properties

@interface BlackjackGame ()

@property (nonatomic, strong) Deck *deck;
@property (nonatomic, assign) State gameState;
@property (nonatomic) NSMutableDictionary<NSString*, NSNumber*> *bets;

@end

// MARK: - Implementation

@implementation BlackjackGame

// MARK: - Static Methods

+ (NSDictionary<NSString*, NSNumber*> *)cardValues {
    return @{@"2": @2, @"3": @3, @"4": @4, @"5": @5, @"6": @6, @"7": @7,
             @"8": @8, @"9": @9, @"10": @10, @"J": @10, @"Q": @10, @"K": @10};
}

+ (NSInteger)cardsAmountToWin {
    return 21;
}

+ (NSInteger)dealerMinimumCardEvaluation {
    return 16;
}

- (NSArray<Player *> *)currentActivePlayers {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *player, NSDictionary *bindings) {
        return player.state == PLAYING;
    }];
    return [self.players filteredArrayUsingPredicate:predicate];
}

- (void)setGameState:(State)gameState {
    _gameState = gameState;
    [self.delegate updateUIForState:self.gameState];
}

// MARK: - Init

- (instancetype)initWithNumberOfPlayers:(NSInteger)numberOfPlayers delegate:(id<BlackjackGameDelegate>)delegate {
    return [self initWithDeck:[PlayingCardDeck new] numberOfPlayers:numberOfPlayers delegate:delegate];
}

- (instancetype)initWithDeck:(Deck *)deck numberOfPlayers:(NSInteger)numberOfPlayers
                    delegate:(id<BlackjackGameDelegate>)delegate {
    self = [super init];
    if (self) {
        NSMutableArray *newPlayers = [NSMutableArray arrayWithCapacity:numberOfPlayers];
        
        for (int i=0; i<numberOfPlayers; i++) {
            NSString *name = [NSString stringWithFormat:@"Player #%d", i+1];
            Player *player = [[Player alloc] initWithName:name chips: 50 delegate:self];
            [newPlayers addObject: player];
        }
        _players = newPlayers;
        _currentPlayer = newPlayers.firstObject;
        _deck = deck;
        _delegate = delegate;
        _bets = [NSMutableDictionary new];
        _dealer = [[Contestant alloc] initWithName:@"Dealer" chips: 0];
    }
    return self;
}

// MARK: - Game Logic

- (void)setDecision:(Decision)decision {
    switch (decision) {
        case HIT: {
            [self.currentPlayer acceptNewCard:[self.deck drawRandomCardWithFaceUp:NO]];
            
            if (self.currentPlayer.state != PLAYING) {
                [self nextPlayer];
            }
            break;
        }
        case STAND:
            [self nextPlayer];
            break;
            
        case SURRENDER: {
            self.currentPlayer.state = LOST;
            [self nextPlayer];
            break;
        }
    }
    [self.delegate updateUIForState:self.gameState];
}

- (void)setBet:(NSInteger)amount {
    if (self.currentPlayer.chips >= amount) {
        [self.bets setObject:[NSNumber numberWithInteger:amount] forKey:self.currentPlayer.identifier];
        self.currentPlayer.chips -= amount;
        [self nextPlayer];
    }
}

- (NSInteger)betAmountForPlayer:(Player *)player {
    return [self.bets valueForKey:player.identifier].integerValue;
}

-(void)nextPlayer {
    NSArray<Player *> *currentActivePlayers = [self currentActivePlayers];
    
    if (currentActivePlayers.count == 0) {
        [self gameOver];
        return;
    }
    
    NSInteger index = [self.players indexOfObject: self.currentPlayer];
    
    if (index < self.players.count - 1) {
        Player *nextPlayer = self.players[index + 1];
        
        if (nextPlayer.state != PLAYING) {
            [self nextPlayer];
        } else {
            self.currentPlayer = nextPlayer;
        }
    } else {
        [self progressGameState];
    }
}

-(void)progressGameState {
    switch (self.gameState) {
        case COLLECT_BETS:
            self.gameState = DEAL_CARDS;
            
        case DEAL_CARDS: {
            self.currentPlayer = self.players.firstObject;
            [self.delegate betsOver];
            [self dealCardsWithDealerFaceUp:YES];
            [self dealCardsWithDealerFaceUp:NO];

            if (self.currentPlayer.state != PLAYING) {
                [self nextPlayer];
            }
            [self.delegate updateUIForState:self.gameState];
            self.gameState = AWAITING_PLAYERS_DECISION;
            break;
        }
            
        case AWAITING_PLAYERS_DECISION:
            self.gameState = AWAITING_DEALER;
            
        case AWAITING_DEALER: {
            [self handleDealerHand];
            [self gameOver];
            break;
            
        case GAMEOVER:
            break;
        }
    }
}

-(void)handleDealerHand {
    [self.dealer.cards.lastObject setIsFaceUp:YES];
    
    while (self.dealer.cardsEvaluation <= BlackjackGame.dealerMinimumCardEvaluation) {
        [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
    }
    [self.delegate updateUIForState:self.gameState];
    
    for (Player *activePlayer in [self currentActivePlayers]) {
        BOOL playerCardsBitDealer = activePlayer.cardsEvaluation > self.dealer.cardsEvaluation;
        BOOL dealerLost = self.dealer.cardsEvaluation > BlackjackGame.cardsAmountToWin;
        
        NSInteger originalBetAmount = [self.bets valueForKey:activePlayer.identifier].integerValue;
        
        if (dealerLost || playerCardsBitDealer) {
            [activePlayer wonChipsAmount:originalBetAmount * 2];
        } else {
            self.dealer.chips += originalBetAmount;
        }
    }
}

-(void)dealCardsWithDealerFaceUp:(BOOL)isDealerCardFaceUp {
    for (Player *player in self.players) {
        [player acceptNewCard:[self.deck drawRandomCardWithFaceUp:NO]];
    }
    [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:isDealerCardFaceUp]];
}

@end

@implementation BlackjackGame (Game)

// MARK: - Game Methods

- (void)startGame {
    self.gameState = COLLECT_BETS;
    [self.delegate updateUIForState:self.gameState];
}

- (void)gameOver {
    self.gameState = GAMEOVER;
    [self.delegate updateUIForState:self.gameState];
}

@end

@implementation BlackjackGame (PlayerDelegate)

- (void)stateUpdatedFor:(Contestant *)player {
    NSInteger playerIndex = [self.players indexOfObject:player];
    [self.delegate updateUIForPlayerAtIndex:playerIndex];
    
    switch(player.state) {
        case PLAYING:
        case GOT_BLACKJACK: {
            NSInteger originalPlayerBet = [self.bets valueForKey:player.identifier].integerValue;
            [player wonChipsAmount:originalPlayerBet * 1.5];
        }
        case LOST:
            self.dealer.chips += [self.bets valueForKey:player.identifier].integerValue;
    }
}

@end
