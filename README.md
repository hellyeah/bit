# Geolocations

A sample app based on Apple's [Locations sample app][locations]. Showcases [`PFQueryTableViewController`][pfqtvc], [`PFGeoPoint`][pfgeopoint], and the use of [`UIStoryboard`][storyboard].

The Geolocations app will add your current location to the list when the `+` button is tapped. Selecting a cell will present a `UIMapView` centered on the `PFGeoPoint` for this `PFObject`.

You can get the [source code][source] and follow along while reading our [Geolocations tutorial][tutorial].

How to Run
----------

1. Clone the repository and open the Xcode project.
2. Add your Parse application id and client key in `AppDelegate.m`.


[locations]: http://developer.apple.com/library/ios/#DOCUMENTATION/DataManagement/Conceptual/iPhoneCoreData01/Introduction/Introduction.html
[pfqtvc]: http://parse.com/docs/ios/api/Classes/PFQueryTableViewController.html
[pfgeopoint]: http://parse.com/docs/ios/api/Classes/PFGeoPoint.html
[storyboard]: https://developer.apple.com/technologies/ios5/
[tutorial]: https://parse.com/tutorials/geolocations
[source]: https://github.com/ParsePlatform/Geolocations