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

+ (NSArray *)rankStrings;
+ (NSArray *)validSuits;
+ (NSInteger)maxRank;

- (NSString *)cardValue;

- (instancetype)initWith:(NSString *)suit rank:(NSInteger)rank;

@end
