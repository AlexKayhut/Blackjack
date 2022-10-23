//
//  PlayingCardDeck.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

- (instancetype)init
{
  self = [super init];
  if (self) {
    for (NSString *suit in PlayingCard.validSuits) {
      for (NSInteger rank = 0; rank <= PlayingCard.maxRank; rank++) {
        PlayingCard *card = [[PlayingCard alloc] initWithSuit:suit rank:rank];
        [super.cards addObject:card];
      }
    }
    [super.cards shuffle];
  }
  return self;
}

@end
