//
//  BlackjackViewController.h
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import "Player.h"

// MARK: - Game Protocol

typedef NS_ENUM(NSInteger, GameState) {
    IN_GAME,
    BETS_OVER,
    ROUND_OVER,
    GAME_OVER
};

@protocol Game

@property (nonatomic, copy, readonly) NSArray<Player *> *_Nonnull players;
@property (nonatomic, assign, readonly) GameState state;
-(void)prepareForNewRound;

@end
