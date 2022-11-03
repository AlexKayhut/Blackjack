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
      Player *player = [[Player alloc] initWithName:name chips:MINIMUM_BUYIN delegate:self];
      [newPlayers addObject: player];
    }
    _players = [newPlayers copy];
    _currentPlayer = newPlayers.firstObject;
    _deck = deck;
    _delegate = delegate;
    _bets = [NSMutableDictionary new];
    _dealer = [[Player alloc] initWithName:@"Dealer" chips:0 delegate:self];
    _state = IN_GAME;
  }
  return self;
}

- (void)setState:(GameState)state {
  _state = state;
  [self.delegate handleChangesforNewState: state];
}

- (void)setCurrentPlayer:(Player *)currentPlayer {
  _currentPlayer = currentPlayer;
  NSInteger index = [self.players indexOfObject:currentPlayer];
  [self.delegate focusOnPlayerAtIndex:index];
  [self.delegate updateUIForPlayerAtIndex:index];
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
  
  [self checkRoundOver];
}

- (void)collectBet:(NSInteger)amount {
  if (self.currentPlayer.chips >= amount) {
    self.bets[self.currentPlayer.identifier] = @(amount);
    [self.currentPlayer collectBet:amount];
    [self nextPlayer];
  } else {
    NSAssert(self.currentPlayer.chips < amount, @"Player should never get to this point");
  }
  
    [self checkBetsOver];
}

-(void)checkBetsOver {
    if (self.bets[self.players.lastObject.identifier]) {
      [self dealCardsFaceUp:YES];
      [self dealCardsFaceUp:NO];
      [self handleFirstPlayerHandAfterCardsDealt];
      self.state = BETS_OVER;
    }
}

-(void)checkRoundOver {
    BOOL isLastPlayer = self.currentPlayer == [self players].lastObject;
    
    if (isLastPlayer) {
      [self finlizeRound];
    } else {
      [self nextPlayer];
    }
}

-(void)handleFirstPlayerHandAfterCardsDealt {
  [self.players.firstObject.cards.lastObject setIsFaceUp:YES];
  
  if (self.currentPlayer == self.players.firstObject && self.currentPlayer.state != PLAYING) {
    [self nextPlayer];
  }
}

-(void)dealCardsFaceUp:(BOOL)isFaceUp {
  for (Player *player in self.players) {
    [player acceptNewCard:[self.deck drawRandomCardWithFaceUp:isFaceUp]];
  }
  [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:isFaceUp]];
}

-(void)nextPlayer {
  NSArray<Player *> *currentActivePlayers = [self currentActivePlayers];
  
  if (self.currentPlayer == currentActivePlayers.lastObject) {
    self.currentPlayer = currentActivePlayers.firstObject;
    [self.delegate updateUIForPlayerAtIndex: currentActivePlayers.count - 1];
  } else {
    NSInteger currentPlayerIndex = [self.players indexOfObject: self.currentPlayer];
    Player *nextPlayer = [self.players objectAtIndex:currentPlayerIndex + 1];
    [nextPlayer showHand];
    self.currentPlayer = nextPlayer;
    [self.delegate updateUIForPlayerAtIndex: currentPlayerIndex];
  }
}

-(void)handleDealerHandAfterPlayersDone {
  [self.dealer.cards.lastObject setIsFaceUp:YES];
  
  while (self.dealer.cardsEvaluation <= DEALER_MINUMUM_CARD_EVALUATION) {
    [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
  }
}

-(void)handlePlayersBetsInRound {
  for (Player *player in self.players) {
    BOOL dealerAndPlayerBust = self.dealer.state == BUST && player.state == BUST;
    BOOL dealerAndPlayerHasEqualEvaluation = player.cardsEvaluation == self.dealer.cardsEvaluation;
    BOOL dealerCardsHigherThenPlayer = self.dealer.cardsEvaluation > player.cardsEvaluation && self.dealer.cardsEvaluation <= CARDS_AMOUNT_TO_WIN;
    BOOL dealerBeatPlayer = dealerCardsHigherThenPlayer || dealerAndPlayerBust;
    
    NSInteger originalBetAmount = self.bets[player.identifier].integerValue;
    [self.bets removeObjectForKey:player.identifier];
    
    switch(player.state) {
      case PLAYING:
      case GOT_BLACKJACK: {
        if (dealerAndPlayerHasEqualEvaluation || dealerBeatPlayer) {
          [player setState:BUST];
          [self.dealer wonChipsAmount:originalBetAmount];
          continue;
        } else {
          float rate = player.state == PLAYING ? 2.0 : 1.5;
          [player wonChipsAmount:originalBetAmount * rate];
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
    [self.delegate updateUIForPlayerAtIndex: [self.players indexOfObject:player]];
  }
}

@end
