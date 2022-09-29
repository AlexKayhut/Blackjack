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
@property (nonatomic, strong) NSMutableArray * _Nullable players;
-(void)startGame:(NSInteger) numberOfPlayers;
-(void)gameOver;
@end


NS_ASSUME_NONNULL_BEGIN

@interface BlackjackGame : NSObject<Game>
@property (nonatomic, strong, readonly) Player *currentPlayer;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) Contestant *dealer;
@property (nonatomic) id<BlackjackGameDelegate> delegate;

- (instancetype)initWith:(Deck *)deck;
- (void)setBet:(NSInteger)amount;
- (void)setDecision:(enum Decision)decision;
@end

NS_ASSUME_NONNULL_END
