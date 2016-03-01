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
  window.localStorage['id'] = 3;
  NgMap.getMap().then(function(map) {
    $rootScope.map = map;
  });
});

app.controller('GroupsCtrl', function ($scope, $location, $http) {
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
  $scope.clock = new Date();
});

app.controller('EventCtrl', function($scope, $http,$window){
  console.log("ciao");
  $scope.custom = true;
  $scope.toggleCustom = function() {
    $scope.custom = $scope.custom === false ? true: false;
  };

  // https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyCmhQc5fBRF5OUDFAawn9L0ZBolUlSw_8k
  // bisogna usare questo circa


  /* invita gruppi */
  var linkPerLaGet = "http://localhost:8888/Mergify/Server/handler.php?userId="+window.localStorage['id'];
  $http.get(linkPerLaGet).success(function(r) {
    $scope.gruppi = r;
  }).error(function(err) {
    console.log(err);
    $scope.gruppi = [
      {
        nome: "Errore",
        id: 1
      },
      {
        nome: "Nella",
        id: 2
      },
      {
        nome: "Get",
        id: 3
      }
    ];
  })





  /*
  POST createEvent
  */

  // per verifiche by ludo -> da cancellare!!!
  // var createEventLinkToPost = "file.json";
  // $http.get(createEventLinkToPost).success(function(data) {
  //   console.log(data);
  // })
  // fine verifiche da cancellareeeeeeee
  // $scope.vm = {};
  // var adesso = new Date();
  // year = adesso.getFullYear();
  // month = adesso.getMonth();
  // monthh = month+1;
  // day = adesso.getDate();
  // console.log(year, month, monthh, day);
  // $scope.vm.dataStart = new Date(year, month, day);
  // $scope.vm.dataEnd = new Date(year, monthh, day);
  $scope.createEvent = function(dataObj) {
    console.log("createEvent")
    if (!angular.isUndefined(dataObj)) {
      count = 0;
      angular.forEach(dataObj, function(v, k) {
        count++;
      });
      if ((count===10)||(count===11)||(count===13)) {
        console.log(JSON.stringify(dataObj))
        // GEOCODING start
        var urlToGmaps = "http://maps.google.com/maps/api/geocode/json?address="+dataObj.address+"+"+dataObj.city+"&sensor=false";
        $http.get(urlToGmaps).success(function (data) {
          console.log(data.results[0].geometry.location);
          // GEOCODING end
          dataObj.lat = data.results[0].geometry.location.lat;
          dataObj.lng = data.results[0].geometry.location.lng;
          // faccio la post
          var createEventLinkToPost = "http://localhost:8888/Mergify/Server/handler.php?action=addEvent&model=event";
          $http.post(createEventLinkToPost, dataObj).success(function(data, status, headers, config) {
            console.info(JSON.stringify(data));
            $scope.data = data;
          }).error(function(data, status, headers, config) {
            console.log(data, config);
            alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
          });
        }).error(function (data) {
          alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
        });


      }
      else {
        console.log("Errore conteggio dati","Non hai compilato tutti i campi!")
      }
    } else {
      console.log("Errore nell'invio del form","Il form risulta essere vuoto.")
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

app.controller('EventsCtrl', function ($scope, $compile, $window,$http, NgMap) {
  $scope.eventsNavbar = true;
  $scope.changeEvents = function( bool ) {
    $scope.eventsNavbar = bool;
  };

// $http.get(urlToNearEvents).success(function(r) {
//   console.log(r);
//   $scope.nearEvents
// }).error(function(err) {
//   console.log(err);
// })

  $scope.gotoEvent = function() {
    window.location.href="#/event";
  }









  // vffanculo

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


app.directive('stringToTimestamp', function() {
  return {
    require: 'ngModel',
    link: function(scope, ele, attr, ngModel) {
      // view to model
      ngModel.$parsers.push(function(value) {
        return Date.parse(value);
      });
    }
  }
});
