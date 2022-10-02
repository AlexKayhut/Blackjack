//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "PlayingCard.h"

// MARK: - Private Properties

@interface BlackjackGame()
@property (nonatomic, strong) Deck *deck;
@property (nonatomic) NSInteger cardsAmountToWin;
@property (nonatomic) NSInteger dealerMinimumCardEvaluation;
@property (nonatomic) enum State gameState;
@property (nonatomic) NSArray *gameStates;
@end

// MARK: - Implementation

@implementation BlackjackGame

@synthesize dealer = _dealer; // because we provide setter AND getter

enum State {
    collectBets, dealCards, awaitingPlayersDecision, awaitingDealerDecision
};

- (Contestant *) dealer {
    if (!_dealer) _dealer = [[Contestant alloc] initWith:@"Dealer" cards:[[NSMutableArray alloc] init] chips: 0 isPlaying:YES];
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
    NSMutableArray *activePlayers = [[NSMutableArray alloc] init];
    for (Player *player in _players) {
        if (player.isPlaying) {
            [activePlayers addObject:player];
        }
    }
    return activePlayers;
}

// MARK: - Init

- (instancetype)initWith:(Deck *)deck {
    self = [super init];
    if (self) {
        _deck = deck;
    }
    return self;
}

// MARK: - Game Methods

- (void)startGame:(NSInteger)numberOfPlayers {
    [self setupContestants:numberOfPlayers];
    _gameState = collectBets;
    [_delegate updateUI];
}

- (void)gameOver {
//    [_dealer.cards removeAllObjects];
}


// MARK: - Game Logic

-(void)setupContestants:(NSInteger) numberOfPlayers {
    [_players removeAllObjects];
    _players = [NSMutableArray arrayWithCapacity:numberOfPlayers];
    
    for (int i=0; i<numberOfPlayers; i++) {
        NSString *name = [NSString stringWithFormat:@"Player #%d", i+1];
        Player *player = [[Player alloc] initWith:name cards:[[NSMutableArray alloc] init] chips: 50 isPlaying:YES];
        [_players addObject: player];
    }
    _currentPlayer = _players.firstObject;
}

- (void)setDecision:(enum Decision)decision {
    switch (decision) {
        case hit:
            [_currentPlayer.cards addObject:[_deck drawRandomCard:YES]];
            NSInteger cardsEvaluation = [self evaluateCardsFor:_currentPlayer];
            [self handlePlayersLogicBasedOn: cardsEvaluation forPlayer: _currentPlayer];
            
            if (!_currentPlayer.isPlaying) {
                [self nextPlayer];
            }
            break;
            
        case stand:
            [self nextPlayer];
            break;
            
        case surrender:
            self.dealer.chips += _currentPlayer.betAmount;
            _currentPlayer.betAmount = 0;
            _currentPlayer.isPlaying = NO;
            [self nextPlayer];
            break;
    }
    [_delegate updateUI];
}

- (void)setBet:(NSInteger)amount {
    if (_currentPlayer.chips >= amount) {
        _currentPlayer.betAmount += amount;
        _currentPlayer.chips -= amount;
        [self nextPlayer];
        [_delegate updateUI];
    }
}

-(void)nextPlayer {
    NSArray *currentActivePlayers = [self currentActivePlayers];

    if (currentActivePlayers.count == 0) {
        [self gameOver];
        return;
    }
    NSInteger index = [_players indexOfObject:_currentPlayer];

    if (index < _players.count - 1) {
        _currentPlayer = _players[index + 1];
    } else if (index == _players.count - 1) {
        
        [self progressGameState];
    } else {
        // TODO: handle case
    }
}

// TODO : encapuslate some logic
-(void)progressGameState {
    switch (_gameState) {
        case collectBets:
            _gameState = dealCards;
        
        case dealCards:
            [self.delegate betsOver];
            [self dealCardsWithDealerFaceUp:YES];
            [self dealCardsWithDealerFaceUp:NO];
            [self evaluateCards];
            [_delegate updateUI];
            _currentPlayer = _players.firstObject;
            _gameState = awaitingPlayersDecision;
            break;
            
        case awaitingPlayersDecision:
            _gameState = awaitingDealerDecision;
            
        case awaitingDealerDecision:
            [self.dealer.cards.lastObject setIsFaceUp:YES];
            NSInteger dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
            while (dealerCardsEvaluation <= [BlackjackGame dealerMinimumCardEvaluation]) {
                [self.dealer.cards addObject:[_deck drawRandomCard:YES]];
                dealerCardsEvaluation = [self evaluateCardsFor:self.dealer];
            }
            [_delegate updateUI];
            
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

-(void)dealCardsWithDealerFaceUp:(BOOL)isDealerCardFaceUp {
    for (Player *player in _players) {
        [player.cards addObject: [_deck drawRandomCard:YES]];
    }
    [self.dealer.cards addObject:[_deck drawRandomCard:isDealerCardFaceUp]];
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
    for (Player *player in _players) {
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
