//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"
#import "BlackjackGame.h"
#import "PlayingCard.h"

@interface Contestant ()

@property (nonatomic) NSArray<Card *> *cards;
@property (nonatomic) NSInteger cardsEvaluation;
@property (nonatomic) NSInteger currentAceCount;

@end

@implementation Contestant

// MARK: Init

- (instancetype)initWithName:(NSString *)name cards:(NSArray *)cards chips:(NSInteger)chips state:(ContestantState)state {
  self = [super init];
  if (self) {
    _name = name;
    _cards = cards;
    _chips = chips;
    _state = state;
    _cardsEvaluation = 0;
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips {
  return [self initWithName:name cards:[NSMutableArray new] chips:chips state:PLAYING];
}

// MARK: Player logic

- (void)prepareForNewRound {
  self.cards = [NSArray new];
  self.state = PLAYING;
  self.cardsEvaluation = 0;
  self.currentAceCount = 0;
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

-(void)updateCardEvaluationWithCard: (PlayingCard *)card {
    if (card.isAce) {
      self.currentAceCount += 1;
      self.cardsEvaluation += [self addAceLogicToCardsEvaluation:self.cardsEvaluation];
    } else {
      self.cardsEvaluation += BlackjackGame.cardValues[card.cardValue].integerValue;
    }

  if (self.cardsEvaluation == BlackjackGame.cardsAmountToWin) {
    self.state = GOT_BLACKJACK;
  } else if (self.cardsEvaluation > BlackjackGame.cardsAmountToWin) {
    self.state = BUST;
  } else {
    self.state = PLAYING;
  }
}

-(NSInteger)addAceLogicToCardsEvaluation:(NSInteger)cardsEvaluation {
  const int aceFirstPossibility = 11;
  const int aceSecondPossibility = 1;
  
  for (int i=0; i<self.currentAceCount;i++) {
    if ((cardsEvaluation + aceFirstPossibility) <= BlackjackGame.cardsAmountToWin) {
      return aceFirstPossibility;
    } else if ((cardsEvaluation + aceSecondPossibility) <= BlackjackGame.cardsAmountToWin) {
      return aceSecondPossibility;
    }
  }
  NSAssert(self.currentAceCount == 0, @"This method is being called when at least 1 Ace (A) found.");
  return 0;
}

@end
