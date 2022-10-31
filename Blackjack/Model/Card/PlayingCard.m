//
//  PlayingCard.m
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "PlayingCard.h"

@implementation PlayingCard

@synthesize suit = _suit;

// MARK: Static

+ (NSArray<NSString *> *)validSuits {
  return @[@"♥️",@"♦️",@"♣️",@"♠️"];
}

+ (NSArray<NSString *> *)rankStrings {
  return @[@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSInteger)maxRank {
  return [PlayingCard.rankStrings count]-1;
}

// MARK: Method

- (NSString *)contents {
  return [[self cardValue] stringByAppendingString:self.suit];
}

- (NSString *)cardValue {
  return PlayingCard.rankStrings[self.rank];
}

- (BOOL)isAce {
  return [self.cardValue isEqual: @"A"];
}

// MARK: Getter/Setter

- (void)setSuit:(NSString *)suit error:(NSError **)error {
  if ([PlayingCard.validSuits containsObject:suit]) {
    _suit = suit;
  } else {
      NSString *message = [NSString stringWithFormat:@"Cant find suit %@", suit];
      *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:NULL];
  }
}

-(void)setRank:(NSInteger)rank error:(NSError **)error {
  if (rank <= PlayingCard.maxRank) {
    _rank = rank;
  } else {
      NSString *message = [NSString stringWithFormat:@"Invalid rank %ld", (long)rank];
      *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:NULL];
  }
}

@end
