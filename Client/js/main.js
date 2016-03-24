var app = angular.module('tutorialWebApp', [
  'ngRoute', 'ngMap', 'naif.base64'
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
  .when("/doc/:id", {templateUrl: "partials/document.html", controller: "DocCtrl",resolve:{Documento:function($routeParams){return $routeParams;}}})
  .when("/profile", {templateUrl: "partials/profile.html", controller: "ProfileCtrl"})
  .when("/groups", {templateUrl: "partials/groups.html", controller: "GroupsCtrl"})
  .when("/group/:id", {templateUrl: "partials/groups.html", controller: "GroupCtrl",resolve:{Gruppo:function($routeParams){return $routeParams;}}})
  .when("/addevent", {templateUrl: "partials/addevent.html", controller: "EventCtrl"})
  .when("/event/:id",{templateUrl:"partials/event.html",controller:"GetEventCtrl",resolve:{Evento:function($routeParams){return $routeParams;}}})
  // .when("/group/:id", {templateUrl: "partials/groups.html", controller: "GroupCtrl"})
  .when("/addgroup", {templateUrl: "partials/addgroup.html", controller: "AddGroupCtrl"})
  // Blog
  .when("/blog", {templateUrl: "partials/blog.html", controller: "BlogCtrl"})
  .when("/blog/post", {templateUrl: "partials/blog_item.html", controller: "BlogCtrl"})
  // else 404
  .otherwise("/404", {templateUrl: "partials/404.html", controller: "PageCtrl"});
}]);

app.run(function($rootScope, NgMap) {
  window.localStorage['id'] = 1;
  $rootScope.url = "http://localhost:8888/MDEF/Server_v02/handler.php";
  $rootScope.urlClient = "http://localhost:8888/MDEF/Client/";
  NgMap.getMap().then(function(map) {
    $rootScope.map = map;
  });
});
