//
//  PlayingCard.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSInteger rank;

+ (NSArray *)validSuits;
+ (NSInteger)maxRank;

@end
