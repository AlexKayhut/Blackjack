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

@protocol PlayerDelegate

-(void)stateUpdatedFor:(Contestant *_Nullable)player;

@end


@interface Player : Contestant

@property (nonatomic, assign) Decision decision;

- (instancetype)initWithName:(NSString *_Nullable)name chips:(NSInteger)chips delegate: (id<PlayerDelegate>_Nullable) delegate;

@end
