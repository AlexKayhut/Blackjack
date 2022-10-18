//
//  BlackjackGame.h
//  Blackjack
//
//  Created by Alex on 28/09/2022.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "Player.h"

// MARK: - BlackjackGame Delegate

@protocol BlackjackGameDelegate

-(void)updateUI;
-(void)betsOver;

@end

// MARK: - Game Protocol

@protocol Game

@property (nonatomic, copy, readonly) NSArray * _Nullable players;
-(void)startGame:(NSInteger) numberOfPlayers;
-(void)gameOver;

@end

NS_ASSUME_NONNULL_BEGIN

@interface BlackjackGame : NSObject

@property (nonatomic, strong) Player *currentPlayer;
@property (nonatomic, copy) NSArray *players;
@property (nonatomic, strong, readonly) Contestant *dealer;
@property (nonatomic) id<BlackjackGameDelegate> delegate;

- (instancetype)initWithDeck:(Deck *)deck;
- (void)setBet:(NSInteger)amount;
- (void)setDecision:(enum Decision)decision;

+ (NSInteger)cardsAmountToWin;
+ (NSInteger)dealerMinimumCardEvaluation;

@end

@interface BlackjackGame (Game) <Game>

-(void)startGame:(NSInteger) numberOfPlayers;
-(void)gameOver;

@end

NS_ASSUME_NONNULL_END
