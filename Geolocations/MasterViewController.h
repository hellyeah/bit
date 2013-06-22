//
//  MasterViewController.h
//  Geolocations
//
//  Created by Héctor Ramos on 7/31/12.
//

#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface MasterViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)insertCurrentLocation:(id)sender;
- (IBAction)insertCurrentLocationWithThumb:(id)sender thumb:(NSNumber *)thumb;
- (void)printObjects:(NSMutableArray *)blah;

@end
