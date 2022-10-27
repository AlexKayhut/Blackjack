//
//  Player.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <Foundation/Foundation.h>
#import "Contestant.h"
#import "Card.h"

typedef NS_ENUM(NSInteger, ContestantState) {
    PLAYING,
    GOT_BLACKJACK,
    BUST
};

typedef NS_ENUM (NSInteger, Decision) {
    HIT,
    STAND,
    SURRENDER
};

@class Player;

@protocol PlayerDelegate

-(void)hasNewChangesForPlayer:(Player *_Nonnull)player;

@end

@interface Player : Contestant

@property (nonatomic, readonly, assign) Decision decision;
@property (nonatomic, readonly, copy, nonnull) NSArray<Card *> *cards;
@property (nonatomic, readonly) NSInteger chips;
@property (nonatomic, readonly) NSInteger cardsEvaluation;
@property (nonatomic, readonly, assign) ContestantState state;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name
                       cards:(NSArray *_Nonnull)cards
                       chips:(NSInteger)chips
                       state: (ContestantState)state
                    delegate:(id<PlayerDelegate>_Nullable)delegate;

- (instancetype _Nonnull)initWithName:(NSString *_Nonnull)name chips:(NSInteger)chips delegate:(id<PlayerDelegate>_Nullable)delegate;

- (void)setState:(ContestantState)state;
- (void)acceptNewCard: (Card *_Nonnull)card;
- (void)wonChipsAmount: (NSInteger)winAmount;
- (void)collectBet:(NSInteger)betAmount;
- (void)prepareForNewRound;

@end
