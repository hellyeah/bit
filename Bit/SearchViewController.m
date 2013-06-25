//
//  SearchViewController.m
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import "SearchViewController.h"
#import "CircleOverlay.h"
#import "GeoPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "parseCSV.h"


enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

enum segmentedControlIndicies {
    kSegmentStandard = 0,
    kSegmentSatellite = 1,
    kSegmentHybrid = 2,
    kSegmentTerrain = 3
};

@interface SearchViewController ()
- (void)heatMapData;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) CircleOverlay *targetOverlay;
@end

@implementation SearchViewController
@synthesize mapView = _mapView;
@synthesize thumbsUp;
@synthesize thumbsDown;
@synthesize buttonsView;
@synthesize hm;
@synthesize setsOfData;

@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
//@synthesize accountStore = _accountStore;

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"geoPointAnnotiationUpdated" object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startLocationManager];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.locationManager startUpdatingLocation];
    
    // Listen for annotation updates. Triggers a refresh whenever an annotation is dragged and dropped.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"geoPointAnnotiationUpdated" object:nil];
    
    self.mapView.region = MKCoordinateRegionMake(self.locationManager.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    
    setsOfData = [[NSMutableDictionary alloc] init];
	
    PFQuery *query = [PFQuery queryWithClassName:@"ImportedLocations"];
    [self extendHeatMapData:query n:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - MasterViewController

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager
{
	if( !_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 100;
        _locationManager.delegate = self;
    }

	return _locationManager;
}

- (IBAction)insertCurrentLocation:(id)sender
{
    [self insertCurrentLocationWithThumb:sender thumb:@YES];
}

- (IBAction)insertCurrentLocationWithThumb:(id)sender thumb:(NSNumber *)thumb
{
	// If it's not possible to get a location, then return.
	CLLocation *location = self.locationManager.location;
	if (!location) {
        NSLog(@"No Location");
		return;
	}
    NSLog(@"YES");
    
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSLog(@"%f",geoPoint.latitude);
    NSLog(@"%f",geoPoint.longitude);
    //NSNumber *thumb = [NSNumber numberWithBool:true];
    
    PFObject *object = [PFObject objectWithClassName:@"Location"];
    
    [object setObject:[NSNumber numberWithBool:thumb] forKey:@"thumb"];
    [object setObject:geoPoint forKey:@"location"];
    
    [object saveInBackground];
    
    //[object saveEventually:^(BOOL succeeded, NSError *error) {
    //}];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [[HeatMapView alloc] initWithOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = YES;
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
        }
        
        return annotationView;
    } 
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        GeoQueryAnnotation *geoQueryAnnotation = (GeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}

#pragma mark - SearchViewController

- (IBAction)thumbsUp:(id)sender
{
    [self insertCurrentLocationWithThumb:sender thumb:[NSNumber numberWithBool:true]];
    [buttonsView setHidden:TRUE];
}

- (IBAction)thumbsDown:(id)sender
{
    [self insertCurrentLocationWithThumb:sender thumb:[NSNumber numberWithBool:false]];
    [buttonsView setHidden:TRUE];
}

- (void)setInitialLocation:(CLLocation *)aLocation
{
    self.location = aLocation;
    self.radius = 1000;
}

#pragma mark - ()

- (IBAction)sliderDidTouchUp:(UISlider *)aSlider
{
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }

    [self configureOverlay];
}

- (IBAction)sliderValueChanged:(UISlider *)aSlider
{
    self.radius = aSlider.value;
    
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }

    self.targetOverlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.mapView addOverlay:self.targetOverlay];
}

- (void)configureOverlay
{
    [self.mapView addOverlay:hm];
    [self.mapView setVisibleMapRect:[hm boundingMapRect] animated:YES];
}

- (void)updateLocations
{
    CGFloat kilometers = self.radius / 1000.0f;

    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
	query.limit = 1000;
	
	PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:kilometers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) return;
		[objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger idx, BOOL *stop) {
			GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc] initWithObject:object];
			[self.mapView addAnnotation:geoPointAnnotation];
		}];
    }];
}

#pragma mark - CLLocationManagerDelegate

/**
 Conditionally enable the Search/Add buttons:
 If the location manager is generating updates, then enable the buttons;
 If the location manager is failing, then disable the buttons.
 */
- (void)startLocationManager
{
	[self.locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude), MKCoordinateSpanMake(0.01, 0.01))];
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 10.0) return;
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    if (self.currentLocation == nil && newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy)
    {
        self.currentLocation = newLocation;
        
        [self stopLocationManager];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
	[self stopLocationManager];
}

- (void)stopLocationManager{
    [self.locationManager stopUpdatingLocation];
}

- (void)heatMapData
{

}

- (void) extendHeatMapData:(PFQuery *)query n:(int)n
{
	[query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
		if (n >= number) {
			[self configureOverlay];
			return;
		}
		
		query.limit = 100;
		query.skip = n;
		
		NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:100];
		
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				for (PFObject *object in objects) {
					PFGeoPoint *location = [object objectForKey:@"location"];
					MKMapPoint point = MKMapPointForCoordinate(CLLocationCoordinate2DMake(location.latitude, location.longitude));
					NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
					if (object[@"thumb"]) toRet[pointValue] = @0.2;
				}
			}
			
			[setsOfData addEntriesFromDictionary:toRet];
			[hm setData:setsOfData];
			[self extendHeatMapData:query n:(n+100)];
		}];
	}];
}

@end
