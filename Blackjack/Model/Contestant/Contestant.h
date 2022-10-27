//
//  Contestant.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Card.h"

typedef NS_ENUM(NSInteger, ContestantState) {
    PLAYING,
    GOT_BLACKJACK,
    BUST
};

@interface Contestant : NSObject

@property (nonatomic, readonly, copy, nonnull) NSString *identifier;
@property (nonatomic, readonly, copy, nonnull) NSString *name;
@property (nonatomic, readonly, copy, nonnull) NSArray<Card *> *cards;
@property (nonatomic, readonly) NSInteger chips;
@property (nonatomic, readonly) NSInteger cardsEvaluation;
@property (nonatomic, assign) ContestantState state;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name
                       cards:(NSArray *_Nonnull)cards
                       chips:(NSInteger)chips
                       state: (ContestantState)state;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name chips:(NSInteger)chips;

- (void)acceptNewCard: (Card *_Nonnull)card;
- (void)wonChipsAmount: (NSInteger)winAmount;
- (void)collectBet:(NSInteger)betAmount;
- (void)prepareForNewRound;

@end
