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

- (instancetype _Nonnull )initWithDeck:(Deck *_Nonnull)deck numberOfPlayers:(NSInteger)numberOfPlayers delegate:(id<BlackjackGameDelegate>_Nullable)delegate;
- (void)setBet:(NSInteger)amount;
- (void)setDecision:(enum Decision)decision;
- (NSInteger)evaluateCardsFor: (Contestant *_Nonnull)contestant;

@end

@interface BlackjackGame (Game) <Game>

-(void)startGame;
-(void)gameOver;

@end
