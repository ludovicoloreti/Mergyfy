app.controller('HomeCtrl', function ($http, $scope, $rootScope, $window) {
  $scope.clock = new Date();
  obj = {}; data = {};
  obj.action = "getUserDocs";
  data.user_id = parseInt(window.localStorage['id']);
  obj.data = data;
  $http.post($rootScope.url, [obj]).success(function(ris) {
  	console.log(ris);
  	$scope.documenti = ris[0].data;
  }).error(function(errore) {
  	alert("trovat un errore!", errore);
  })
  $scope.goto = function(id) {
  	var link = "#/doc/"+id;
    window.location.href = $rootScope.urlClient+link;
  }
});
