//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "PlayingCard.h"

// MARK: - Private Properties

@interface BlackjackGame ()

@property (nonatomic, strong) Deck *deck;
@property (nonatomic, assign) State gameState;

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
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *object,
                                                                   NSDictionary *bindings) {
        return object.isPlaying;  // Return YES for each object you want in filteredArray.
    }];
    return [self.players filteredArrayUsingPredicate:predicate];
}

// MARK: - Init

- (instancetype)initWithDeck:(Deck *)deck numberOfPlayers:(NSInteger)numberOfPlayers delegate:(id<BlackjackGameDelegate>)delegate {
    self = [super init];
    if (self) {
        NSMutableArray *newPlayers = [NSMutableArray arrayWithCapacity:numberOfPlayers];
        
        for (int i=0; i<numberOfPlayers; i++) {
            NSString *name = [NSString stringWithFormat:@"Player #%d", i+1];
            Player *player = [[Player alloc] initWithName:name chips: 50];
            [newPlayers addObject: player];
        }
        _players = newPlayers;
        _currentPlayer = newPlayers.firstObject;
        _deck = deck;
        _delegate = delegate;
        _dealer = [[Contestant alloc] initWithName:@"Dealer" chips: 0];
    }
    return self;
}

// MARK: - Game Logic

- (void)setDecision:(Decision)decision {
    switch (decision) {
        case HIT: {
            [self.currentPlayer.cards addObject:[self.deck drawRandomCardWithFaceUp:NO]];
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
    [self.delegate updateUIForState:self.gameState];
}

- (void)setBet:(NSInteger)amount {
    if (self.currentPlayer.chips >= amount) {
        self.currentPlayer.betAmount += amount;
        self.currentPlayer.chips -= amount;
        [self nextPlayer];
        [self.delegate updateUIForState:self.gameState];
    }
}

-(void)nextPlayer {
    NSArray<Player *> *currentActivePlayers = [self currentActivePlayers];
    
    if (currentActivePlayers.count == 0) {
        [self gameOver];
        return;
    }
    
    NSInteger index = [self.players indexOfObject: self.currentPlayer];
    
    if (index < self.players.count - 1) {
        self.currentPlayer = self.players[index + 1];
        if (self.currentPlayer.isPlaying == NO) {
            [self nextPlayer];
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
            [self evaluateCards];
            if (!self.currentPlayer.isPlaying) {
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
    NSInteger dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
    
    while (dealerCardsEvaluation <= BlackjackGame.dealerMinimumCardEvaluation) {
        [self.dealer.cards addObject:[self.deck drawRandomCardWithFaceUp:YES]];
        dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
    }
    [self.delegate updateUIForState:self.gameState];
    
    for (Player *activePlayer in [self currentActivePlayers]) {
        BOOL playerCardsBitDealer = activePlayer.cardsEvaluation > self.dealer.cardsEvaluation;
        BOOL dealerLost = self.dealer.cardsEvaluation > BlackjackGame.cardsAmountToWin;
        
        if (dealerLost || playerCardsBitDealer) {
            activePlayer.chips += activePlayer.betAmount * 2;
        } else {
            self.dealer.chips += activePlayer.betAmount;
            activePlayer.isPlaying = NO;
        }
        activePlayer.betAmount = 0;
    }
}

-(void)dealCardsWithDealerFaceUp:(BOOL)isDealerCardFaceUp {
    for (Player *player in self.players) {
        [player.cards addObject: [self.deck drawRandomCardWithFaceUp:NO]];
    }
    [self.dealer.cards addObject:[self.deck drawRandomCardWithFaceUp:isDealerCardFaceUp]];
}

-(void)handlePlayersLogicBasedOn: (NSInteger)cardsEvaluation forPlayer:(Player *)player {
    if (cardsEvaluation == BlackjackGame.cardsAmountToWin) {
        player.isPlaying = NO;
        player.chips = player.betAmount * 1.5;
        player.betAmount = 0;
    } else if (cardsEvaluation > BlackjackGame.cardsAmountToWin) {
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
        sum += BlackjackGame.cardValues[value.cardValue].integerValue;
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

- (void)startGame {
    self.gameState = COLLECT_BETS;
    [self.delegate updateUIForState:self.gameState];
}

- (void)gameOver {
    self.gameState = GAMEOVER;
    [self.delegate updateUIForState:self.gameState];
}

@end
