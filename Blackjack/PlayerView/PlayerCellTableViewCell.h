//
//  PlayerCellTableViewCell.h
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *chips;
@property (weak, nonatomic) IBOutlet UILabel *currentBet;
@property (weak, nonatomic) IBOutlet UIStackView *cardsStackView;

@end

NS_ASSUME_NONNULL_END
