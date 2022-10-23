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

@synthesize suit = _suit; // because we provide setter AND getter

- (instancetype)initWithSuit:(NSString *)suit rank:(NSInteger)rank {
  self = [super init];
  if (self) {
    _rank = rank;
    _suit = suit;
  }
  return self;
}

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

// MARK: Getter/Setter

- (void)setSuit:(NSString *)suit {
  if ([PlayingCard.validSuits containsObject:suit]) {
    _suit = suit;
  }
}

- (NSString *)suit {
  return _suit ? _suit : @"?";
}

-(void)setRank:(NSInteger)rank {
  if (rank <= PlayingCard.maxRank) {
    _rank = rank;
  }
}

@end
