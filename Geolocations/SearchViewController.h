//
//  SearchViewController.h
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "HeatMap.h"
#import "HeatMapView.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SearchViewController : UIViewController <MKMapViewDelegate,
    CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISlider *slider;

- (IBAction)thumbsUp:(id)sender;
- (IBAction)thumbsDown:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *thumbsUp;
@property (strong, nonatomic) IBOutlet UIButton *thumbsDown;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) HeatMap *hm;
@property  (strong, nonatomic) NSMutableDictionary *setsOfData;

- (IBAction)insertCurrentLocation:(id)sender;
- (IBAction)insertCurrentLocationWithThumb:(id)sender thumb:(NSNumber *)thumb;

- (void)setInitialLocation:(CLLocation *)aLocation;

- (void)startLocationManager;
- (void)stopLocationManager;
- (void) extendHeatMapData:(PFQuery *)query n:(int)n;

//@property (nonatomic) ACAccountStore *accountStore;
//- (void)grabTweets;

@end
