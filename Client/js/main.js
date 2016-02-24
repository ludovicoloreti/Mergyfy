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
    .when("/event", {templateUrl: "partials/event.html",controller: "EventCtrl"})
    .when("/faq", {templateUrl: "partials/faq.html", controller: "PageCtrl"})
    .when("/profile", {templateUrl: "partials/profile.html", controller: "PageCtrl"})
    .when("/services", {templateUrl: "partials/services.html", controller: "PageCtrl"})
    .when("/contact", {templateUrl: "partials/contact.html", controller: "PageCtrl"})
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
app.controller('EventCtrl', function ($scope, $compile, $window, NgMap) {
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

  /*$scope.centerOnMe = function() {

   if(!$scope.map) {
   return;
   }

   navigator.geolocation.getCurrentPosition(function(pos) {
   var miaPosizione = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
   $scope.map.setCenter(miaPosizione);
   var mappa2Options = {
   center: miaPosizione,
   zoom: 15,
   mapTypeId: google.maps.MapTypeId.ROADMAP
   };
   var mappa2 = new google.maps.Map(document.getElementById("map-canvas"),
   mappa2Options);
   /!* Portami in piazza Scaravilli :D *!/
   var directionsService = new google.maps.DirectionsService();
   var directionsDisplay = new google.maps.DirectionsRenderer();
   plazaScaravilli = new google.maps.LatLng(44.497063, 11.352284);
   var request = {
   origin : miaPosizione,
   destination : plazaScaravilli,
   travelMode : google.maps.TravelMode.WALKING
   };
   directionsService.route(request, function(response, status) {
   if (status == google.maps.DirectionsStatus.OK) {
   directionsDisplay.setDirections(response);
   }
   });

   directionsDisplay.setMap(mappa2);

   }, function(error) {
   switch(error.code) {
   case error.PERMISSION_DENIED:
   alert('Impossibile stabilire la posizione: \n' + error.message);
   $window.location.reload(true);
   break;
   case error.POSITION_UNAVAILABLE:
   alert('Impossibile stabilire la posizione: \n' + error.message);
   $window.location.reload(true);
   break;
   case error.TIMEOUT:
   alert('Tempo impiegato troppo lungo: \n' + error.message);
   $window.location.reload(true);
   break;
   case error.UNKNOWN_ERROR:
   alert('Errore nello stabilire la posizione: \n' + error.message);
   $window.location.reload(true);
   break;
   default:
   alert('Impossibile stabilire la posizione: ' + error.message);
   $window.location.reload(true);
   }
   });
   }*/
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
