//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "Deck.h"
#import "Contestant.h"
#import "PlayingCardDeck.h"
#import "Player.h"

@interface BlackjackGame()
@property (nonatomic, strong) Deck *deck;
@property (nonatomic) NSInteger round;
@end

@implementation BlackjackGame

- (NSInteger) round {
    if (!_round) _round = 0;
    return _round;
}

- (Contestant *) dealer {
    if (!_dealer) _dealer = [[Contestant alloc] initWith:@"Dealer" cards:[[NSMutableArray alloc] init] chips: 0];
    return _dealer;
}

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
}

- (void)gameOver {
    // TO DO: Show game over
}


// MARK: - Game Init

-(void)setupContestants:(NSInteger) numberOfPlayers {
    [_players removeAllObjects];
    _players = [NSMutableArray arrayWithCapacity:numberOfPlayers];
    
    for (int i=0; i<numberOfPlayers; i++) {
        NSString *name = [NSString stringWithFormat:@"Player #%d", i+1];
        Player *player = [[Player alloc] initWith:name cards:[[NSMutableArray alloc] init] chips: 50];
        [_players addObject: player];
    }
    _currentPlayer = _players.firstObject;
}

- (void)setDecision:(enum Decision)decision {
    switch (decision) {
        case hit:
            [_currentPlayer.cards addObject:[_deck drawRandomCard:YES]];
            break;
        case stand:
            [self nextPlayer];
            break;
        case surrender:
            self.dealer.chips += _currentPlayer.betAmount;
            _currentPlayer.betAmount = 0;
            [self nextPlayer];
            break;
    }
    [_delegate updateUI];
}

- (void)setBet:(NSInteger)amount {
    if (_currentPlayer.chips >= amount) {
        _currentPlayer.betAmount += amount;
        _currentPlayer.chips -= amount;
        if (_currentPlayer == _players.lastObject) {
            [self dealCards:YES];
            [self dealCards:NO];
        }
        
        if (_currentPlayer == _players.lastObject) {
            [_delegate betsOver];
        }
        
        [self nextPlayer];
    } else {
        // TO DO: Show alert
    }
    [_delegate updateUI];
}

-(void)nextPlayer {
    NSInteger index = [_players indexOfObject:_currentPlayer];
    if (index < _players.count - 1) {
        _currentPlayer = _players[index + 1];
    } else {
        _currentPlayer = _players.firstObject;
    }
}

-(void)dealCards:(BOOL)isDealerCardFaceUp {
    for (Player *player in _players) {
        [player.cards addObject: [_deck drawRandomCard:YES]];
    }
    [self.dealer.cards addObject:[_deck drawRandomCard:isDealerCardFaceUp]];
}

@end
