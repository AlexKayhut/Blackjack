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
    NSError *error;
    for (NSString *suit in PlayingCard.validSuits) {
      for (NSInteger rank = 0; rank <= PlayingCard.maxRank; rank++) {
        PlayingCard *card = [PlayingCard new];
        [card setSuit:suit error:&error];
        [card setRank:rank error:&error];
        if (error) {
          // show alert?
          NSLog(error.domain.description);
          return nil;
        }
        [super addCard:card];
      }
    }
    [super shuffle];
  }
  return self;
}

@end
