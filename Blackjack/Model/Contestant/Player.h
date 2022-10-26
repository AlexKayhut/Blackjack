//
//  Player.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

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

- (instancetype _Nullable)initWithName:(NSString *_Nonnull)name
                                 cards:(NSArray *_Nonnull)cards
                                 chips:(NSInteger)chips
                                 state:(ContestantState)state
                              delegate:(id<PlayerDelegate>_Nullable) delegate;

- (instancetype _Nullable)initWithName:(NSString *_Nonnull)name
                                 chips:(NSInteger)chips
                              delegate:(id<PlayerDelegate>_Nullable) delegate;

@end
