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
  .when("/doc", {templateUrl: "partials/document.html", controller: "DocCtrl"})
  .when("/profile", {templateUrl: "partials/profile.html", controller: "PageCtrl"})
  .when("/groups", {templateUrl: "partials/groups.html", controller: "GroupsCtrl"})
  .when("/addevent", {templateUrl: "partials/addevent.html", controller: "EventCtrl"})
  .when("/event", {templateUrl: "partials/event.html", controller: "EventCtrl"})
  .when("/group", {templateUrl: "partials/group.html", controller: "GroupCtrl"})
  .when("/addgroup", {templateUrl: "partials/addgroup.html", controller: "AddGroupCtrl"})
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

app.controller('GroupsCtrl', function ($scope, $location, $http) {
  console.log("Blog Controller reporting for duty.");
  $scope.lol = "lololol";
});


app.controller('GroupCtrl', function ($scope) {
  $scope.edit = false;
  $scope.editGroup = function() {
    $scope.edit = true;
  };

  $scope.saveChanges = function() {
    $scope.edit = false;
  };
});

app.controller('AddGroupCtrl', function (/* $scope, $location, $http */) {
});

// nuovo controller
app.controller('HomeCtrl', function ($scope) {
  $scope.clock = Date.now();
});

app.controller('EventCtrl', function($scope, $http){
  console.log("ciao");
  $scope.custom = true;
  $scope.toggleCustom = function() {
    $scope.custom = $scope.custom === false ? true: false;
  };

  // https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyCmhQc5fBRF5OUDFAawn9L0ZBolUlSw_8k
  // bisogna usare questo circa



  /*
  POST createEvent
  */

  // per verifiche by ludo -> da cancellare!!!
  // var createEventLinkToPost = "file.json";
  // $http.get(createEventLinkToPost).success(function(data) {
  //   console.log(data);
  // })
  // fine verifiche da cancellareeeeeeee

  $scope.createEvent = function(dataObj) {
    console.log("createEvent")
    if (!angular.isUndefined(dataObj)) {
      count = 0;
      angular.forEach(dataObj, function(v, k) {
        count++;
      });
      if (count===8) {
        console.log(JSON.stringify(dataObj))
        // GEOCODING start
        var urlToGmaps = "http://maps.google.com/maps/api/geocode/json?address="+dataObj.address+"+"+dataObj.city+"&sensor=false";
        $http.get(urlToGmaps).success(function (data) {
          console.log(data.results[0].geometry.location);
          // GEOCODING end
          dataObj.lat = data.results[0].geometry.location.lat;
          dataObj.lng = data.results[0].geometry.location.lng;
          var objToPost = {
            model: "event",
            action: "addEvvent",
            param: dataObj
          }
          // faccio la post
          var createEventLinkToPost = "http://localhost:8888/Mergify/Server/handler.php";
          $http.post(createEventLinkToPost, objToPost).success(function(data, status, headers, config) {
            console.info(data);
            $scope.data = data;
          }).error(function(data, status, headers, config) {
            console.log(data, status, headers, config);
            alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
          });
        }).error(function (data) {
          alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
        });


      }
      else {
        console.err("Errore conteggio dati","Non hai compilato tutti i campi!")
      }
    } else {
      console.err("Errore nell'invio del form","Il form risulta essere vuoto.")
    }
  }

});

app.controller('DocCtrl', function($scope){
  $scope.toggle = false;
  $scope.toggleView = function() {
    $scope.toggle = ($scope.toggle) ? false : true;
  };

  $scope.title= "";
  $scope.text= "";
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

    var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

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
    var center = this.map.getCenter();
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
