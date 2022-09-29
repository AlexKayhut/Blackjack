//
//  BlackjackViewController.h
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import <UIKit/UIKit.h>
#import "BlackjackGame.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlackjackViewController : UIViewController <BlackjackGameDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) NSInteger numberOfPlayers;
@end

NS_ASSUME_NONNULL_END
