//
//  Player.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import "Contestant.h"

enum Decision {
    hit, stand, surrender
};


NS_ASSUME_NONNULL_BEGIN

@interface Player : Contestant
@property (nonatomic) NSInteger betAmount;
@property (nonatomic) enum Decision decision;
@end

NS_ASSUME_NONNULL_END
