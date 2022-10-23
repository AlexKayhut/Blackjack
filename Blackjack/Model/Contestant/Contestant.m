//
//  Contestant.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

@implementation Contestant

- (instancetype)initWithName:(NSString *)name
                       cards:(NSMutableArray *)cards
                       chips:(NSInteger)chips
                   isPlaying:(BOOL)isPlaying {
  self = [super init];
  if (self) {
    _name = name;
    _cards = cards;
    _chips = chips;
    _isPlaying = isPlaying;
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips {
  self = [super init];
  if (self) {
    _name = name;
    _chips = chips;
    _cards = [NSMutableArray new];
    _isPlaying = YES;
  }
  return self;
}

-(NSMutableArray *) cards {
  if (!_cards) {
    _cards = [NSMutableArray new];
  }
  return _cards;
}

- (NSInteger)cardsEvaluation {
  if (!_cardsEvaluation) {
    _cardsEvaluation = 0;
  }
  return _cardsEvaluation;
}

@end
