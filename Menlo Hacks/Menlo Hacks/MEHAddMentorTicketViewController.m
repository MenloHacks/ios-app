//
//  MEHAddMentorTicketViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHAddMentorTicketViewController.h"

#import <Bolts/Bolts.h>

#import "SCLAlertView.h"

#import "UIColor+ColorPalette.h"
#import "MEHMentorshipStoreController.h"

@interface MEHAddMentorTicketViewController ()

@end

@implementation MEHAddMentorTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = [UIColor menloHacksPurple];
    alert.shouldDismissOnTapOutside = YES;
    
    
    UITextField *descriptionField = [alert addTextField:@"Describe your issue"];
    UITextField *locationField = [alert addTextField:@"Where are you located?"];
    UITextField *contactField = [alert addTextField:@"email, phone, etc"];
    
    
    [alert addButton:@"Submit" validationBlock:^BOOL{
        //Maybe add validation instead of just relying on server, but time is limited.
        return YES;
    } actionBlock:^{
     //   dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[MEHMentorshipStoreController sharedMentorshipStoreController]createTicket:descriptionField.text
                                                                                location:locationField.text
                                                                                 contact:contactField.text]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                if(!t.error) {
                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                    alert.customViewColor = [UIColor menloHacksPurple];
                    alert.shouldDismissOnTapOutside = YES;
                    [alert showSuccess:@"Ticket created" subTitle:nil closeButtonTitle:@"Ok" duration:3.0];
                    [alert alertIsDismissed:^{
//                        dispatch_semaphore_signal(semaphore);
                    }];
                } else {
         //           dispatch_semaphore_signal(semaphore);
                }
                
                return nil;
            }];
        });
        
        
      //  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
    }];
    

    
    [alert showQuestion:@"Create a ticket" subTitle:nil closeButtonTitle:@"Cancel" duration:0];
    
    

    
    [alert alertIsDismissed:^{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
