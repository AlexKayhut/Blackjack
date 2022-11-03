//
//  Deck.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface Deck ()

@property (nonatomic, copy) NSArray *cards;

@end

@implementation Deck

- (NSArray *)cards {
  if (!_cards) {
    _cards = [NSArray new];
  }
  return _cards;
}

- (Card *)drawRandomCardWithFaceUp:(BOOL) isFaceUp {
  NSMutableArray *mutableCards = [[NSMutableArray alloc] initWithArray:self.cards];
  Card *randomCard = mutableCards.firstObject;
  randomCard.isFaceUp = isFaceUp;
  [mutableCards removeObjectAtIndex:0];
  self.cards = mutableCards;
  return randomCard;
}

- (void)addCard:(Card *)card {
  [self addCard:card atTop:NO];
}

- (void)addCard:(Card *)card atTop:(BOOL)atTop {
  NSMutableArray *mutableCards = [[NSMutableArray alloc] initWithArray:self.cards];
  if (atTop) {
    [mutableCards insertObject:card atIndex:0];
  } else {
    [mutableCards addObject:card];
  }
  self.cards = mutableCards;
}

- (void)shuffle {
  NSMutableArray *mutableCards = [[NSMutableArray alloc] initWithArray:self.cards];
  [mutableCards shuffle];
  self.cards = mutableCards;
}

@end
