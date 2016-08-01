//
//  SettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "PokemonSelectTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

NSString * const SettingsChangedNotification = @"Poke.SettingsChangedNotification";
NSString * const ServerChangedNotification = @"Poke.ServerChangedNotification";
NSString * const BackgroundSettingChangedNotification = @"Poke.BackgroundSettingChangedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readSavedState];
}

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.serverField.text = [prefs valueForKey:@"server_addr"];
    
    [self.pokemonsSwitch setOn:[prefs boolForKey:@"display_pokemons"]];
    [self.pokestopsSwitch setOn:[prefs boolForKey:@"display_pokestops"]];
    [self.gymsSwitch setOn:[prefs boolForKey:@"display_gyms"]];
    [self.commonSwitch setOn:[prefs boolForKey:@"display_common"]];
    [self.viewOnlyFavoriteSwitch setOn:[prefs boolForKey:@"display_onlyfav"]];
    [self.distanceSwitch setOn:[prefs boolForKey:@"display_distance"]];
    [self.timeSwitch setOn:[prefs boolForKey:@"display_time"]];
    [self.timeTimerSwitch setOn:[prefs boolForKey:@"display_timer"]];
    [self.backgroundSwitch setOn:[prefs boolForKey:@"run_in_background"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *favs = [prefs objectForKey:@"pokemon_favorite"];
        NSInteger count = [favs count];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Using the setter, it seems to work well
            [self.viewOnlyFavoriteSwitch setOn:count > 0];
        });
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"showPokemonSelect"]) {
		PokemonSelectTableViewController *destViewController = segue.destinationViewController;

		switch (((UITableViewCell *)sender).tag) {
			case SELECT_COMMON:
				destViewController.title = NSLocalizedString(@"Common", @"The title of the Pokémon selection for common Pokémon.") ;
				destViewController.preferenceKey = @"pokemon_common";
				break;
			case SELECT_FAVORITE:
				destViewController.title = NSLocalizedString(@"Favorite", @"The title of the Pokémon selection for favorite Pokémon.");
				destViewController.preferenceKey = @"pokemon_favorite";
				break;
			default:
				break;
		}
	}
}

-(IBAction)saveAction:(UIBarButtonItem *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *server = [self.serverField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![server containsString:@"://"] && [server length] > 0) {
        server = [NSString stringWithFormat:@"http://%@", server];
        self.serverField.text = server;
    }
    
    if ([server length] == 0 || [server containsString:@"//127.0.0.1"] || [server containsString:@"//localhost"] || [server containsString:@"//10."] || [server containsString:@"//192.168."]) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Invalid server address", @"Alert warning the user that the server address was invalid")
                                    message:NSLocalizedString(@"Please change your server address to one that is reachable on the internet.", @"Ask the user to use a URL that will work through the internet")
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction
                          actionWithTitle:NSLocalizedString(@"OK", @"A common affirmative action title, like 'OK' in english.")
                          style:UIAlertActionStyleDefault
                          handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
        
    } else {
        if (![[prefs objectForKey:@"server_addr"] isEqualToString:server]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
            [prefs setObject:server forKey:@"server_addr"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingsChangedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.pokemonsSwitch) {
        [prefs setBool:self.pokemonsSwitch.on forKey:@"display_pokemons"];
        
    } else if (sender == self.gymsSwitch) {
        [prefs setBool:self.gymsSwitch.on forKey:@"display_gyms"];
        
    } else if (sender == self.commonSwitch) {
        [prefs setBool:self.commonSwitch.on forKey:@"display_common"];
        
    } else if (sender == self.distanceSwitch) {
        [prefs setBool:self.distanceSwitch.on forKey:@"display_distance"];
        
    } else if (sender == self.timeSwitch) {
        [prefs setBool:self.timeSwitch.on forKey:@"display_time"];
		self.timeTimerSwitch.enabled = self.timeSwitch.on;
			
    } else if (sender == self.timeTimerSwitch) {
        [prefs setBool:self.timeTimerSwitch.on forKey:@"display_timer"];
        
    } else if (sender == self.viewOnlyFavoriteSwitch) {
        [prefs setBool:self.viewOnlyFavoriteSwitch.on forKey:@"display_onlyfav"];
        
    } else if (sender == self.backgroundSwitch) {
        [prefs setBool:self.backgroundSwitch.on forKey:@"run_in_background"];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackgroundSettingChangedNotification object:nil];
        
    } else if (sender == self.pokestopsSwitch) {
        [prefs setBool:self.pokestopsSwitch.on forKey:@"display_pokestops"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
