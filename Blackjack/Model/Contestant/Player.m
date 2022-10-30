//
//  Player.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Player.h"
#import "PlayingCard.h"
#import "BlackjackGame.h"

@interface Player ()

@property (nonatomic) NSArray<Card *> *cards;
@property (nonatomic) NSInteger cardsEvaluation;
@property (nonatomic) NSInteger cardsEvaluationWithoutAces;
@property (nonatomic) NSInteger currentAceCount;
@property (nonatomic) NSInteger chips;
@property (nonatomic, weak, nullable) id<PlayerDelegate> delegate;

@end

@implementation Player

// MARK: Init

- (instancetype)initWithName:(NSString *)name cards:(NSArray *)cards chips:(NSInteger)chips state:(ContestantState)state delegate:(id<PlayerDelegate> _Nullable)delegate {
  self = [super initWithName:name];
  if (self) {
    _cards = cards;
    _chips = chips;
    _state = state;
    _delegate = delegate;
    _cardsEvaluation = 0;
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips delegate:(id<PlayerDelegate> _Nullable)delegate {
  return [self initWithName:name cards:[NSMutableArray new] chips:chips state:PLAYING delegate:delegate];
}

- (void)setState:(ContestantState)state {
  _state = state;
  [self.delegate hasNewChangesForPlayer:self];
}

- (BOOL)didPlayRound {
  return self.cards.lastObject.isFaceUp;
}

// MARK: Player logic

- (void)prepareForNewRound {
  self.cards = [NSArray new];
  self.cardsEvaluation = 0;
  self.cardsEvaluationWithoutAces = 0;
  self.currentAceCount = 0;
  self.state = PLAYING;
}

- (void)acceptNewCard:(PlayingCard *)card {
  NSMutableArray<Card *> *mutableCards = [NSMutableArray arrayWithCapacity:self.cards.count];
  [mutableCards addObjectsFromArray:self.cards];
  [mutableCards addObject:card];
  self.cards = mutableCards;
  [self updateCardEvaluationWithCard:card];
}

- (void)wonChipsAmount:(NSInteger)winAmount {
  self.chips += winAmount;
  self.state = GOT_BLACKJACK;
}

- (void)collectBet:(NSInteger)betAmount {
  self.chips -= betAmount;
}

- (void)showHand {
  [self.cards.lastObject setIsFaceUp:YES];
}

-(void)updateCardEvaluationWithCard: (PlayingCard *)card {
  if (card.isAce) {
    self.currentAceCount += 1;
    self.cardsEvaluation += [self getBestAceValueForCardsEvaluation:self.cardsEvaluation];
  } else {
    self.cardsEvaluation += CARDS_VALUE[card.cardValue].integerValue;
    self.cardsEvaluationWithoutAces += CARDS_VALUE[card.cardValue].integerValue;
  }
  
  BOOL shouldReEvaluteCardsWithAces = self.currentAceCount > 0 && self.cardsEvaluation > CARDS_AMOUNT_TO_WIN && self.cardsEvaluationWithoutAces < CARDS_AMOUNT_TO_WIN;
  
  if (shouldReEvaluteCardsWithAces) {
    self.cardsEvaluation = self.cardsEvaluationWithoutAces + [self getBestAceValueForCardsEvaluation:self.cardsEvaluationWithoutAces];
  }
  
  if (self.cardsEvaluation == CARDS_AMOUNT_TO_WIN) {
    self.state = GOT_BLACKJACK;
  } else if (self.cardsEvaluation > CARDS_AMOUNT_TO_WIN) {
    self.state = BUST;
  } else {
    self.state = PLAYING;
  }
}

-(NSInteger)getBestAceValueForCardsEvaluation:(NSInteger)cardsEvaluation {
  NSAssert(self.currentAceCount != 0, @"This method is being called when at least 1 Ace (A) found.");
  
  const int aceFirstPossibility = 11;
  const int aceSecondPossibility = 1;
  
  for (int i=0; i<self.currentAceCount;i++) {
    if ((cardsEvaluation + aceFirstPossibility) <= CARDS_AMOUNT_TO_WIN) {
      return aceFirstPossibility;
    } else if ((cardsEvaluation + aceSecondPossibility) <= CARDS_AMOUNT_TO_WIN) {
      return aceSecondPossibility;
    }
  }
  return 0;
}

@end
