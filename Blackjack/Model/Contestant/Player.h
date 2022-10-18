//
//  Player.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

typedef NS_ENUM (NSInteger, Decision) {
    HIT, STAND, SURRENDER
};

NS_ASSUME_NONNULL_BEGIN

@interface Player : Contestant
@property (nonatomic) NSInteger betAmount;
@property (nonatomic, assign) Decision decision;

@end

NS_ASSUME_NONNULL_END
