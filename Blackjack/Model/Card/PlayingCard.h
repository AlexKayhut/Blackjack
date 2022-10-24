//
//  PlayingCard.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Card.h"

@interface PlayingCard : Card

@property (nonatomic, copy, readonly) NSString *suit;
@property (nonatomic, readonly) NSInteger rank;

@property (nonatomic, readonly, class) NSArray<NSString *> *rankStrings;
@property (nonatomic, readonly, class) NSArray<NSString *> *validSuits;
@property (nonatomic, readonly, class) NSInteger maxRank;

- (NSString *)cardValue;
- (BOOL)isAce;

- (instancetype)initWithSuit:(NSString *)suit rank:(NSInteger)rank;

@end
