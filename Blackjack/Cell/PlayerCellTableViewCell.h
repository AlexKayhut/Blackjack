//
//  PlayerCellTableViewCell.h
//  Blackjack
//
//  Created by Alex on 29/09/2022.
//

#import <UIKit/UIKit.h>

@interface PlayerCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *chips;
@property (weak, nonatomic) IBOutlet UILabel *currentBet;
@property (weak, nonatomic) IBOutlet UIStackView *cardsStackView;
@property (weak, nonatomic) IBOutlet UILabel *cardEvaluationLabel;
@property (nonatomic, readonly, class) NSString *identifier;

- (void)updateTextColorTo:(UIColor *)color;

@end
