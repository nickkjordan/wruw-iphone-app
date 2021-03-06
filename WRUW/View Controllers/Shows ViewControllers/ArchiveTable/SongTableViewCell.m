#import "SongTableViewCell.h"
#import <QuartzCore/CALayer.h>
#import "WRUWModule-Swift.h"

@interface SongTableViewCell(){ }

@end

@implementation SongTableViewCell

@synthesize nameLabel, artistLabel, albumLabel, thumbnailImageView, socialView, favButton, facebookButton, twitterButton, view;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    socialView.hidden = !socialView.hidden;
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    thumbnailImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    thumbnailImageView.layer.shadowOffset = CGSizeMake(2, 2);
    thumbnailImageView.layer.shadowOpacity = 0.36;
    thumbnailImageView.layer.shadowRadius = 2.0;
    thumbnailImageView.clipsToBounds = NO;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.36;
    view.layer.shadowRadius = 0.5;
    view.clipsToBounds = NO;
}

- (void)layoutSubviews {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:nameLabel.text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:0];
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrString.length)];
    nameLabel.attributedText = attrString;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize labelSize = (CGSize){self.nameLabel.bounds.size.width, FLT_MAX};
    CGRect r = [self.nameLabel.attributedText.string boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNextCondensed-Bold" size:16]} context:context];
    
    if (r.size.height > 25) {
        CGRect frame = self.artistLabel.frame;
        frame.origin.y = 56;
        self.artistLabel.frame = frame;
    } else if (self.artistLabel.frame.origin.y == 56) {
        CGRect frame = self.artistLabel.frame;
        frame.origin.y = 48;
        self.artistLabel.frame = frame;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    [UILabel animateWithDuration:0.5
                      animations:^{
                          self->nameLabel.alpha = !selected;
                          self->artistLabel.alpha = !selected;
                          self->albumLabel.alpha = !selected;
                          self->socialView.alpha = selected;
                      }];
}

-(BOOL)saveFavorite:(Song *)currentSong {
    BOOL favorited = [FavoriteManager.instance saveFavoriteWithSong:currentSong];

    if (!favorited) {
        NSDictionary *dataDict2=
            [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:self]
                                        forKeys:[NSArray arrayWithObject:@"cell"]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"notification"
                                                            object:self
                                                          userInfo:dataDict2];
    }

    return favorited;
}

- (IBAction)favoritePush:(id)sender {
    BOOL favorited = [self saveFavorite:_currentSong];
    
    NSString *switchHeart = favorited ? @"heart_24_red.png" : @"heart_24.png";
    
    [self buttonAnimation:favButton withImage:switchHeart];
}

- (IBAction)composeFBPost:(id)sender {
    [self postSocial:SLServiceTypeFacebook];
    [self buttonAnimation:facebookButton withImage:@"facebook_blue.png"];
}

- (IBAction)composeTwitterPost:(id)sender {
    [self postSocial:SLServiceTypeTwitter];
    [self buttonAnimation:twitterButton withImage:@"twitter_blue.png"];
}

-(void)postSocial:(NSString *)serviceType{
    SocialComposeViewController *socialController = (SocialComposeViewController *)
        [SocialComposeViewController composeViewControllerForServiceType:serviceType];
    
    UIImage *albumArt = thumbnailImageView.image;
    NSString *postText =
        [NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",
                                   nameLabel.text,
                                   artistLabel.text];

    [socialController setInitialText:postText];
    [socialController addURL:[NSURL URLWithString:@"wruw.org"]];
    [socialController addImage:albumArt];

    [socialController showWithAnimated:true completion:nil];
}

-(void)buttonAnimation:(UIButton *)button withImage:(NSString *)imageName {
    UIImage *toImage = [UIImage imageNamed:imageName];
    
    [UIView transitionWithView:self.socialView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        button.imageView.animationImages = [NSArray arrayWithObjects:toImage,nil];
                        [button.imageView startAnimating];
                        [button setImage:toImage forState:UIControlStateNormal];
                    }
                    completion:nil];
    
}

- (IBAction)searchSong:(id)sender {
    NSString *artist = [artistLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *title = [nameLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"https://www.google.com/search?q=%@+%@", title, artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)configureForSong:(Song *)song {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:song.songName];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:0];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, song.songName.length)];
    self.nameLabel.attributedText = attrString;
    self.albumLabel.text = [@[song.album, song.label] componentsJoinedByString:@" · "];
    self.artistLabel.text = song.artist;
    self.currentSong = song;
    
    [thumbnailImageView setImage:song.image];
}

@end
