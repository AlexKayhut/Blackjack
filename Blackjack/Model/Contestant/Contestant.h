//
//  Contestant.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Card.h"

typedef NS_ENUM(NSInteger, ContestantState) {
    BETTING,
    PLAYING,
    GOT_BLACKJACK,
    LOST
};

@interface Contestant : NSObject

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) NSArray<Card *> *cards;
@property (nonatomic) NSInteger chips;
@property (nonatomic, readonly) NSInteger cardsEvaluation;
@property (nonatomic, assign) ContestantState state;

- (instancetype)initWithName:(NSString *)name
                       cards:(NSMutableArray *)cards
                       chips:(NSInteger)chips
                       state: (ContestantState)state;

- (instancetype)initWithName:(NSString *)name chips:(NSInteger)chips;

- (void)acceptNewCard: (Card *)card;
- (void)wonChipsAmount: (NSInteger)winAmount;

@end
