//
//  BlackjackGame.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <UIKit/UIKit.h>
#import "Player.h"

// MARK: - BlackjackGame Delegate

@protocol BlackjackGameDelegate

-(void)updateUIForDealer;
-(void)updateUIForPlayerAtIndex:(NSArray<NSNumber *>*_Nonnull)array;
-(void)focusOnPlayerAtIndex: (NSInteger)index;
-(void)betsOver;
-(void)gameOver;
-(void)roundOver;

@end

// MARK: - Game Protocol

@protocol Game

@property (nonatomic, copy, readonly) NSArray<Player *> *_Nonnull players;
-(void)prepareForNewRound;

@end

@interface BlackjackGame : NSObject

@property (nonatomic, strong, readonly, nonnull) Player *currentPlayer;
@property (nonatomic, strong, readonly, nonnull) Contestant *dealer;
@property (nonatomic, weak, nullable) id<BlackjackGameDelegate> delegate;

// MARK: class properties

@property (nonatomic, readonly, class) NSInteger cardsAmountToWin;
@property (nonatomic, readonly, class) NSInteger dealerMinimumCardEvaluation;
@property (nonatomic, readonly, class, nonnull) NSDictionary<NSString*, NSNumber*> *cardValues;

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
