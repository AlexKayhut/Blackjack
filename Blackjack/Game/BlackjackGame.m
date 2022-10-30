//
//  BlackjackGame.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "BlackjackGame.h"
#import "PlayingCardDeck.h"
#import "Player.h"

// MARK: - Private Properties

@interface BlackjackGame ()

@property (nonatomic, strong) Deck *deck;
@property (nonatomic, copy) NSMutableDictionary<NSString*, NSNumber*> *bets;
@property (nonatomic, strong, nonnull) Player *currentPlayer;
@property (nonatomic, copy, nonnull) NSArray<Player *> *players;
@property (nonatomic, assign) GameState state;

@end

const NSInteger CARDS_AMOUNT_TO_WIN = 21;
const NSInteger DEALER_MINUMUM_CARD_EVALUATION = 16;

const NSDictionary<NSString*, NSNumber*> *CARDS_VALUE = @{@"2": @2, @"3": @3, @"4": @4,
                                                          @"5": @5, @"6": @6, @"7": @7,
                                                          @"8": @8, @"9": @9, @"10": @10,
                                                          @"J": @10, @"Q": @10, @"K": @10};

// MARK: - Implementation

@implementation BlackjackGame

// MARK: - Static Methods

const NSInteger MINIMUM_BUYIN = 50;
const NSInteger MINIMUM_ROUND_BET = 5;

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
      Player *player = [[Player alloc] initWithName:name chips: MINIMUM_BUYIN delegate:self];
      [newPlayers addObject: player];
    }
    _players = newPlayers;
    _currentPlayer = newPlayers.firstObject;
    _deck = deck;
    _delegate = delegate;
    _bets = [NSMutableDictionary new];
    _dealer = [[Player alloc] initWithName:@"Dealer" chips: 0 delegate:self];
    _state = IN_GAME;
  }
  return self;
}

- (void)setState:(GameState)state {
  _state = state;
  [self.delegate handleChangesforNewState: state];
}

// MARK: - Player Filters

- (NSInteger)getBetAmountForPlayer:(Player *)player {
  return [self.bets valueForKey:player.identifier].integerValue;
}

- (NSArray<Player *> *)currentActivePlayers {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *player, NSDictionary *bindings) {
    return player.state == PLAYING;
  }];
  return [self.players filteredArrayUsingPredicate:predicate];
}

- (NSArray<Player *> *)playersAvailableForNextFound {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *player, NSDictionary *bindings) {
    return player.chips >= MINIMUM_ROUND_BET;
  }];
  return [self.players filteredArrayUsingPredicate:predicate];
}

// MARK: - Game Logic

- (void)collectDecision:(Decision)decision {
  BOOL isLastPlayer = self.currentPlayer == [self currentActivePlayers].lastObject;
  
  switch (decision) {
    case HIT: {
      [self.currentPlayer acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
      
      if (self.currentPlayer.state == PLAYING) {
        return;
      }
      break;
    }
      
    case SURRENDER:
      [self.currentPlayer setState:BUST];
      
    case STAND: {
      break;
    }
  }
  
  if (isLastPlayer) {
    [self finlizeRound];
  } else {
    [self nextPlayer];
  }
}

- (void)collectBet:(NSInteger)amount {
  if (self.currentPlayer.chips >= amount) {
    [self.bets setObject:[NSNumber numberWithInteger:amount] forKey:self.currentPlayer.identifier];
    [self.currentPlayer collectBet:amount];
    [self nextPlayer];
  } else {
    NSAssert(self.currentPlayer.chips < amount, @"Player should never get to this point");
  }
  
  if (self.bets[self.players.lastObject.identifier]) {
    [self dealCardsFaceUp:YES];
    [self dealCardsFaceUp:NO];
    
    if (self.currentPlayer == self.players.firstObject && self.currentPlayer.state != PLAYING) {
      [self nextPlayer];
    }
    self.state = BETS_OVER;
  }
}

-(void)dealCardsFaceUp:(BOOL)isFaceUp {
  for (Player *player in self.players) {
    BOOL _isFaceUp = player == self.players.firstObject ? YES : isFaceUp;
    [player acceptNewCard:[self.deck drawRandomCardWithFaceUp:_isFaceUp]];
  }
  [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:isFaceUp]];
}

-(void)nextPlayer {
  NSMutableArray<NSNumber *> *playersIndexToUpdated = [NSMutableArray new];
  
  if (self.currentPlayer != self.players.lastObject) {
    NSNumber *currentPlayerIndex = [NSNumber numberWithInteger:[self.players indexOfObject: self.currentPlayer]];
    [playersIndexToUpdated addObject:currentPlayerIndex];
    
    Player *nextPlayer = self.players[currentPlayerIndex.intValue + 1];
    [nextPlayer showHand];
    self.currentPlayer = nextPlayer;
    
    NSNumber *nextPlayerIndex = [NSNumber numberWithInteger:[self.players indexOfObject: nextPlayer]];
    [playersIndexToUpdated addObject:nextPlayerIndex];
    
    [self.delegate focusOnPlayerAtIndex:playersIndexToUpdated.lastObject.integerValue];
  } else {
    NSArray<Player *> *currentActivePlayers = [self currentActivePlayers];
    
    self.currentPlayer = currentActivePlayers.firstObject;
    [playersIndexToUpdated addObject:[NSNumber numberWithInteger:0]];
    [playersIndexToUpdated addObject:[NSNumber numberWithInteger: currentActivePlayers.count - 1]];
    [self.delegate focusOnPlayerAtIndex:0];
  }
  
  [self.delegate updateUIForPlayerAtIndex: playersIndexToUpdated];
}

-(void)handleDealerHandAfterPlayersDone {
  [self.dealer.cards.lastObject setIsFaceUp:YES];
  
  while (self.dealer.cardsEvaluation <= DEALER_MINUMUM_CARD_EVALUATION) {
    [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
  }
}

-(void)handlePlayersBetsInRound {
  for (Player *player in self.players) {
    BOOL dealerBeatPlayer = (self.dealer.cardsEvaluation > player.cardsEvaluation && self.dealer.cardsEvaluation <= CARDS_AMOUNT_TO_WIN) || (self.dealer.state == BUST && player.state == BUST);
    BOOL playerAndDealerEqualEvaluation = player.cardsEvaluation == self.dealer.cardsEvaluation;
    NSLog( @"%@", [NSString stringWithFormat:@"%@, %ld, %ld", player.name, (long)player.cardsEvaluation, (long)self.dealer.cardsEvaluation]);
    
    NSInteger originalBetAmount = self.bets[player.identifier].integerValue;
    [self.bets removeObjectForKey:player.identifier];
    
    switch(player.state) {
      case PLAYING:
      case GOT_BLACKJACK: {
        if (playerAndDealerEqualEvaluation || dealerBeatPlayer) {
          [player setState:BUST];
          [self.dealer wonChipsAmount:originalBetAmount];
          continue;
        } else {
          float rate = player.state == PLAYING ? 2.0 : 1.5;
          [player wonChipsAmount:originalBetAmount * rate];
          [self.delegate updateUIForPlayerAtIndex:[NSArray arrayWithObjects:[NSNumber numberWithInteger:[self.players indexOfObject:player]], nil]];
        }
        break;
      }
        
      case BUST: {
        [player setState:BUST];
        [self.dealer wonChipsAmount:originalBetAmount];
      }
    }
  }
}

- (void)finlizeRound {
  [self handleDealerHandAfterPlayersDone];
  [self handlePlayersBetsInRound];
  
  if ([self playersAvailableForNextFound].count > 1) {
    self.state = ROUND_OVER;
  } else {
    self.state = GAME_OVER;
  }
}

@end

// MARK: - Game Methods

@implementation BlackjackGame (Game)

- (void)prepareForNewRound {
  [self.bets removeAllObjects];
  self.deck = [PlayingCardDeck new];
  self.players = [self playersAvailableForNextFound];
  self.currentPlayer = self.players.firstObject;
  for (Player *player in self.players) {
    [player prepareForNewRound];
  }
  [self.dealer prepareForNewRound];
  self.state = IN_GAME;
}

@end

// MARK: - Player Delegate

@implementation BlackjackGame (PlayerDelegate)

- (void)hasNewChangesForPlayer:(Player *)player {
  if (player == self.dealer) {
    [self.delegate updateUIForDealer];
  } else if (player == self.currentPlayer) {
    [self.delegate updateUIForPlayerAtIndex:[NSArray arrayWithObjects:[NSNumber numberWithInteger:[self.players indexOfObject:player]], nil]];
  }
}

@end
