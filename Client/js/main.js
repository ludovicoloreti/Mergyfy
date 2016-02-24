/**
 * AngularJS Tutorial 1
 * @author Nick Kaye <nick.c.kaye@gmail.com>
 */

/**
 * Main AngularJS Web Application
 */
var app = angular.module('tutorialWebApp', [
  'ngRoute', 'ngMap'
]);

/**
 * Configure the Routes
 */
app.config(['$routeProvider', function ($routeProvider) {
  $routeProvider
  // Home
    .when("/", {templateUrl: "partials/home.html", controller: "HomeCtrl"})
    // Pages
    .when("/events", {templateUrl: "partials/events.html",controller: "EventsCtrl"})
    .when("/doc", {templateUrl: "partials/document.html", controller: "PageCtrl"})
    .when("/profile", {templateUrl: "partials/profile.html", controller: "PageCtrl"})
    .when("/services", {templateUrl: "partials/services.html", controller: "PageCtrl"})
    .when("/addevent", {templateUrl: "partials/addevent.html", controller: "PageCtrl"})
    .when("/event", {templateUrl: "partials/event.html", controller: "EventCtrl"})

    // Blog
    .when("/blog", {templateUrl: "partials/blog.html", controller: "BlogCtrl"})
    .when("/blog/post", {templateUrl: "partials/blog_item.html", controller: "BlogCtrl"})
    // else 404
    .otherwise("/404", {templateUrl: "partials/404.html", controller: "PageCtrl"});
}]);

app.run(function($rootScope, NgMap) {
  NgMap.getMap().then(function(map) {
    $rootScope.map = map;
  });
});

/**
 * Controls the Blog
 */
app.controller('BlogCtrl', function (/* $scope, $location, $http */) {
  console.log("Blog Controller reporting for duty.");
});

// nuovo controller
app.controller('HomeCtrl', function ($scope) {
    $scope.clock = Date.now();
});

app.controller('EventCtrl', function(){

});

app.controller('EventsCtrl', function ($scope, $compile, $window, NgMap) {
  $scope.eventsNavbar = true;
  $scope.changeEvents = function( bool ) {
    $scope.eventsNavbar = bool;
  };

  NgMap.getMap().then(function(map) {
    console.log(map.getCenter());
    console.log('markers', map.markers);
    console.log('shapes', map.shapes);
  });



  var map;
  $window.init = function() {
    var latitude = 44.488851,
      longitude = 11.297554,
      center = new google.maps.LatLng(latitude,longitude),
      mapOptions = {
        center: center,
        zoom: 14,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        scrollwheel: false
      };

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

    setMarkers(center, map);
  }

  function setMarkers(center, map) {

    latLng = new google.maps.LatLng(44.488851, 11.297554);
    var marker = new google.maps.Marker({
      position: latLng,
      map: map,
      title: "Polyflash di Boiani Alberto"
    });

  }

  function resize() {
    var center = map.getCenter();
    google.maps.event.trigger(map, "resize");
    map.setCenter(center);
  }

  // google.maps.event.addDomListener(window, 'load', initialize);
  google.maps.event.addDomListener(window, "resize", resize);


});
// fine nuovo controller

/**
 * Controls all other Pages
 */
app.controller('PageCtrl', function (/* $scope, $location, $http */) {
  console.log("Page Controller reporting for duty.");

  // Activates the Carousel
  $('.carousel').carousel({
    interval: 5000
  });

  // Activates Tooltips for Social Links
  $('.tooltip-social').tooltip({
    selector: "a[data-toggle=tooltip]"
  })
});
