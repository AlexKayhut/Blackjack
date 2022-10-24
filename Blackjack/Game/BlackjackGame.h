//
//  BlackjackGame.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Player.h"

typedef NS_ENUM(NSInteger, State) {
    COLLECT_BETS,
    DEAL_CARDS,
    AWAITING_PLAYERS_DECISION,
    AWAITING_DEALER,
    GAMEOVER
};

// MARK: - BlackjackGame Delegate

@protocol BlackjackGameDelegate

-(void)updateUIForState:(State) state;
-(void)updateUIForPlayerAtIndex:(NSInteger)index;
-(void)betsOver;

@end

// MARK: - Game Protocol

@protocol Game

@property (nonatomic, copy, readonly) NSArray<Player *> * _Nullable players;
-(void)startGame;
-(void)gameOver;

@end

@interface BlackjackGame : NSObject

@property (nonatomic, strong, nullable) Player *currentPlayer;
@property (nonatomic, copy, nullable) NSArray<Player *> *players;
@property (nonatomic, strong, readonly, nullable) Contestant *dealer;
@property (nonatomic, weak, nullable) id<BlackjackGameDelegate> delegate;
@property (nonatomic, readonly, assign) State gameState;

// MARK: class properties

@property (nonatomic, readonly, class) NSInteger cardsAmountToWin;
@property (nonatomic, readonly, class) NSInteger dealerMinimumCardEvaluation;
@property (nonatomic, readonly, class) NSDictionary<NSString*, NSNumber*> * _Nullable cardValues;

- (instancetype _Nonnull )initWithNumberOfPlayers:(NSInteger)numberOfPlayers delegate:(id<BlackjackGameDelegate>_Nullable)delegate;
- (void)setBet:(NSInteger)amount;
- (void)setDecision:(enum Decision)decision;
- (NSInteger)betAmountForPlayer:(Player *_Nonnull)player;

@end

@interface BlackjackGame (Game) <Game>

-(void)startGame;
-(void)gameOver;

@end

@interface BlackjackGame (PlayerDelegate) <PlayerDelegate>

-(void)stateUpdatedFor:(Contestant *_Nullable)player;

@end
