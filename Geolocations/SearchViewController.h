//
//  SearchViewController.h
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface SearchViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISlider *slider;

- (void)setInitialLocation:(CLLocation *)aLocation;
- (IBAction)thumbsDown:(id)sender;

- (IBAction)insertCurrentLocationWithThumb:(id)sender thumb:(NSNumber *)thumb;
- (void)printObjects:(NSMutableArray *)blah;

@end
