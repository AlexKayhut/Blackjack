//
//  Deck.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface Deck ()

@property (nonatomic, copy) NSMutableArray *cards;

@end

@implementation Deck

- (NSMutableArray *)cards {
  if (!_cards) {
    _cards = [NSMutableArray new];
  }
  return _cards;
}

- (Card *)drawRandomCard:(BOOL) isFaceUp {
  Card *randomCard = self.cards.firstObject;
  randomCard.isFaceUp = isFaceUp;
  [self.cards removeObjectAtIndex:0];
  return randomCard;
}

- (void)addCard:(Card *)card {
  [self addCard:card atTop:NO];
}

- (void)addCard:(Card *)card atTop:(BOOL)atTop {
  if (atTop) {
    [self.cards insertObject:card atIndex:0];
  } else {
    [self.cards addObject:card];
  }
}

- (void)shuffle {
  [self.cards shuffle];
}

@end
