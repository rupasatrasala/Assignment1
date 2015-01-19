//
//  SettingsViewController.m
//  TipCalculator
//
//  Created by Rupa Satrasala on 1/13/15.
//  Copyright (c) 2015 Personal. All rights reserved.
//

#import "SettingsViewController.h"
#import "TipViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *defaultTipPercentageText;
@property (strong, nonatomic) IBOutlet UITextField *defaultSpliValueText;
@property (strong, nonatomic) IBOutlet UITableView *payHistoryTable;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (retain, nonatomic) NSMutableArray *tabledata;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSaveButtonTapped)];
    _defaults = [NSUserDefaults standardUserDefaults];
    [_payHistoryTable setDelegate:self];
    [_payHistoryTable setDataSource:self];
    [self updateDefaultValues];
    
}

- (void) updateDefaultValues {
    int defaultTip = [_defaults floatForKey:@"default_tip"];
    if (defaultTip > 0) {
        [_defaultTipPercentageText setText: [NSString stringWithFormat:@"%d",defaultTip]];
    }
    int defaultSplit = [_defaults floatForKey:@"default_split"];
    if (defaultSplit > 0) {
        [_defaultSpliValueText setText: [NSString stringWithFormat:@"%d", defaultSplit]];
    }
    _tabledata = [_defaults objectForKey:@"table_data"];

}

- (void) viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onSaveButtonTapped {
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_defaultTipPercentageText.text forKey:@"default_tip"];
    [defaults setObject:_defaultSpliValueText.text forKey:@"default_split"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) updateHistory {
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tabledata count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [_tabledata objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blueColor];
    
    return cell;
}

@end
