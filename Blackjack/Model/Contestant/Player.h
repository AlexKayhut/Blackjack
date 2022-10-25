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

@interface Player : Contestant

@property (nonatomic, assign) Decision decision;

- (instancetype _Nullable)initWithName:(NSString *_Nonnull)name
                       cards:(NSArray *_Nonnull)cards
                       chips:(NSInteger)chips
                       state: (ContestantState)state
                    delegate: (id<PlayerDelegate>_Nullable) delegate;

- (instancetype _Nullable)initWithName:(NSString *_Nullable)name
                                 chips:(NSInteger)chips
                              delegate: (id<PlayerDelegate>_Nullable) delegate;

@end
