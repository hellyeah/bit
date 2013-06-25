//
//  CircleAnnotation.m
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import "CircleOverlay.h"

@implementation CircleOverlay
@synthesize radius = _radius;
@synthesize coordinate = _coordinate;


#pragma mark - Initialization

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius {
    self = [super init];
    if (self) {
        _coordinate = aCoordinate;
        _radius = aRadius;
    }
    return self;
}


#pragma mark - MKAnnotation

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

- (MKMapRect)boundingMapRect {
    MKMapPoint centerMapPoint = MKMapPointForCoordinate(_coordinate);
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(_coordinate, _radius * 2, _radius * 2);
    return MKMapRectMake(centerMapPoint.x,
                         centerMapPoint.y,
                         region.span.latitudeDelta,
                         region.span.longitudeDelta);
}

@end
