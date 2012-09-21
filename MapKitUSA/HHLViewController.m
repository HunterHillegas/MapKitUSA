//
//  HHLViewController.m
//  MapKitUSA
//
//  Created by Hunter Hillegas on 9/21/12.
//  Copyright (c) 2012 Hanchor LLC. All rights reserved.
//

#import "HHLViewController.h"

@interface HHLViewController ()

@property (nonatomic, strong) IBOutlet MKMapView *stateMapView;

@end

@implementation HHLViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *overlays = [HHLViewController usStatesAndTerritoryOverlays];
    [self.stateMapView addOverlays:overlays];
}

#pragma mark - Map Delegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView *aView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];

        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.65];
        aView.lineWidth = 2;
        
        return aView;
    }
    
    return nil;
}

#pragma mark - Utilities

+ (NSArray *)usStatesAndTerritoryOverlays {
    NSString *fileName = [[NSBundle mainBundle] pathForResource:@"states" ofType:@"json"];
    NSData *overlayData = [NSData dataWithContentsOfFile:fileName];

    id parsedJSON = [NSJSONSerialization JSONObjectWithData:overlayData options:NSJSONReadingAllowFragments error:nil];

    NSArray *states = [parsedJSON valueForKeyPath:@"states.state"];

    NSMutableArray *overlays = [NSMutableArray array];

    for (NSDictionary *state in states) {
        NSArray *points = [state valueForKeyPath:@"point"];

        NSInteger numberOfCoordinates = [points count];
        CLLocationCoordinate2D *polygonPoints = malloc(numberOfCoordinates * sizeof(CLLocationCoordinate2D));

        NSInteger index = 0;
        for (NSDictionary *pointDict in points) {
            polygonPoints[index] = CLLocationCoordinate2DMake([[pointDict valueForKeyPath:@"latitude"] floatValue], [[pointDict valueForKeyPath:@"longitude"] floatValue]);
            index++;
        }

        MKPolygon *overlayPolygon = [MKPolygon polygonWithCoordinates:polygonPoints count:numberOfCoordinates];
        overlayPolygon.title = [state valueForKey:@"name"];

        [overlays addObject:overlayPolygon];

        free(polygonPoints);
    }
    
    return overlays;
}

@end
