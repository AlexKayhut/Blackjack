//
//  BlackjackGame.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <UIKit/UIKit.h>
#import "Player.h"

typedef NS_ENUM(NSInteger, GameState) {
    IN_GAME,
    BETS_OVER,
    ROUND_OVER,
    GAME_OVER
};

// MARK: - BlackjackGame Delegate

@protocol BlackjackGameDelegate

-(void)updateUIForDealer;
-(void)updateUIForPlayerAtIndex:(NSArray<NSNumber *>*_Nonnull)array;
-(void)focusOnPlayerAtIndex:(NSInteger)index;
-(void)handleChangesforNewState:(GameState)state;

@end

// MARK: - Game Protocol

@protocol Game

@property (nonatomic, copy, readonly) NSArray<Player *> *_Nonnull players;
@property (nonatomic, assign, readonly) GameState state;
-(void)prepareForNewRound;

@end

extern const NSInteger CARDS_AMOUNT_TO_WIN;
extern const NSInteger DEALER_MINUMUM_CARD_EVALUATION;
extern const NSDictionary<NSString*, NSNumber*> * _Nonnull CARDS_VALUE;

@interface BlackjackGame : NSObject

@property (nonatomic, strong, readonly, nonnull) Player *currentPlayer;
@property (nonatomic, strong, readonly, nonnull) Player *dealer;
@property (nonatomic, weak, nullable) id<BlackjackGameDelegate> delegate;

- (instancetype _Nonnull )initWithNumberOfPlayers:(NSInteger)numberOfPlayers
                                         delegate:(id<BlackjackGameDelegate>_Nullable)delegate;
- (void)collectBet:(NSInteger)amount;
- (void)collectDecision:(Decision)decision;
- (NSInteger)getBetAmountForPlayer:(Player *_Nonnull)player;

@end

// MARK: Game Protocol

@interface BlackjackGame (Game) <Game>

-(void)prepareForNewRound;

@end

// MARK: Player Delegate

@interface BlackjackGame (PlayerDelegate) <PlayerDelegate>

-(void)hasNewChangesForPlayer:(Player *_Nullable)player;

@end
