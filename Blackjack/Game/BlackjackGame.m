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

@end

// MARK: - Implementation

@implementation BlackjackGame

const NSInteger minimumBuyin = 50;
const NSInteger minimumRoundBet = 5;

- (NSInteger)getBetAmountForPlayer:(Player *)player {
  return [self.bets valueForKey:player.identifier].integerValue;
}

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
      Player *player = [[Player alloc] initWithName:name chips: minimumBuyin delegate:self];
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

// MARK: - Player Filters

- (NSArray<Player *> *)currentActivePlayers {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *player, NSDictionary *bindings) {
    return player.state == PLAYING;
  }];
  return [self.players filteredArrayUsingPredicate:predicate];
}

- (NSArray<Player *> *)playersAvailableForNextFound {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Player *player, NSDictionary *bindings) {
    return player.chips >= minimumRoundBet;
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
      self.currentPlayer.state = BUST;
      
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
    [self.delegate betsOver];
    [self dealCardsWithDealerFaceUp:YES];
    [self dealCardsWithDealerFaceUp:NO];
    
    if (self.currentPlayer.state != PLAYING) {
      [self nextPlayer];
    }
    [self.delegate updateUIForDealer];
  }
}

-(void)dealCardsWithDealerFaceUp:(BOOL)isDealerCardFaceUp {
  for (Player *player in self.players) {
    [player acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
  }
  [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:isDealerCardFaceUp]];
}


-(void)nextPlayer {
  if (self.currentPlayer != self.players.lastObject) {
    NSInteger index = [self.players indexOfObject: self.currentPlayer];
    Player *nextPlayer = self.players[index + 1];
    
    switch(nextPlayer.state) {
      case GOT_BLACKJACK:
      case BUST: {
        self.currentPlayer = nextPlayer;
        [self nextPlayer];
        break;
      }
        
      case PLAYING: {
        NSNumber *currentPlayerIndex = [NSNumber numberWithInteger:[self.players indexOfObject: self.currentPlayer]];
        self.currentPlayer = nextPlayer;
        NSNumber *nextPlayerIndex = [NSNumber numberWithInteger:[self.players indexOfObject: nextPlayer]];
        [self.delegate updateUIForPlayerAtIndex: [NSArray arrayWithObjects:currentPlayerIndex, nextPlayerIndex, nil]];
        [self.delegate focusOnPlayerAtIndex:nextPlayerIndex.integerValue];
      }
    }
  } else {
    self.currentPlayer = [self currentActivePlayers].firstObject;
    [self.delegate focusOnPlayerAtIndex:[self.players indexOfObject: self.currentPlayer]];
  }
}

-(void)handleDealerHandAfterPlayersDone {
  [self.dealer.cards.lastObject setIsFaceUp:YES];
  
  while (self.dealer.cardsEvaluation <= BlackjackGame.dealerMinimumCardEvaluation) {
    [self.dealer acceptNewCard:[self.deck drawRandomCardWithFaceUp:YES]];
  }
  [self.delegate updateUIForDealer];
}

-(void)handlePlayersBetsInRound {
  for (Player *player in self.players) {
    BOOL dealerBitPlayer = (self.dealer.cardsEvaluation > player.cardsEvaluation && self.dealer.cardsEvaluation <= BlackjackGame.cardsAmountToWin) || (self.dealer.state == BUST && player.state == BUST);
    BOOL playerAndDealerEqualEvaluation = player.cardsEvaluation == self.dealer.cardsEvaluation;
    NSLog( @"%@", [NSString stringWithFormat:@"%@, %ld, %ld", player.name, (long)player.cardsEvaluation, (long)self.dealer.cardsEvaluation]);
    
    
    NSInteger originalBetAmount = self.bets[player.identifier].integerValue;
    [self.bets removeObjectForKey:player.identifier];
    
    switch(player.state) {
      case PLAYING:
      case GOT_BLACKJACK: {
        
        if (playerAndDealerEqualEvaluation || dealerBitPlayer) {
          player.state = BUST;
          [self.dealer wonChipsAmount:originalBetAmount];
          [self.delegate updateUIForDealer];
          continue;
        } else {
          float rate = player.state == PLAYING ? 2.0 : 1.5;
          [player wonChipsAmount:originalBetAmount * rate];
          [self.delegate updateUIForPlayerAtIndex:[NSArray arrayWithObjects:[NSNumber numberWithInteger:[self.players indexOfObject:player]], nil]];
        }
        break;
      }
        
      case BUST: {
        [self.dealer wonChipsAmount:originalBetAmount];
        [self.delegate updateUIForDealer];
      }
    }
  }
}

- (void)finlizeRound {
  [self handleDealerHandAfterPlayersDone];
  [self handlePlayersBetsInRound];
  
  if ([self playersAvailableForNextFound].count > 1) {
    [self.delegate roundOver];
  } else {
    [self.delegate gameOver];
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
}

@end

// MARK: - Player Delegate

@implementation BlackjackGame (PlayerDelegate)

- (void)hasNewChangesForPlayer:(Player *)player {
  [self.delegate updateUIForPlayerAtIndex:[NSArray arrayWithObjects:[NSNumber numberWithInteger:[self.players indexOfObject:player]], nil]];
}

@end
