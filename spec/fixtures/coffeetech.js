// BEGIN MODULE_DEFINITION
var mod = angular.module( 'coffeetech', [] );

mod.factory( 'Github', function() {
    return new Github({});
});
// END MODULE_DEFINITION

mod.factory( 'Geo', [ '$window', function( $window ) {
    return $window.navigator.geolocation;
} ] );

mod.controller( 'GithubCtrl', [ '$scope', 'Github', 'Geo', function( $scope, ghs, Geo ) {
    $scope.messages = []

    $scope.init = function() {
        $scope.getCurrentLocation( function( position ) {
            $scope.latitude = position.coords.latitude;
            $scope.longitude = position.coords.longitude;

// BEGIN FOOBAR

alert( "Something" );

// END FOOBAR
