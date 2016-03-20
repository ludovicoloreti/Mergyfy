app.controller('GroupsCtrl', function ($scope, $location, $http, $rootScope) {
    $scope.cane = false;
  obj = {}; data = {};
  obj.action = "getUserGroups";
  data.user_id = parseInt(window.localStorage['id']);
  obj.data = data;
  $http.post($rootScope.url, [obj]).success(function(res) {
    console.log(res);
    $scope.groups = res[0].data;
  }).error(function(error) {
    console.log(error, "non vaaaa");
  })
  $scope.view = function(id) {
    var link = "#/group/"+id;
    console.log("clicked on a group link. Going to -> "+link)
    window.location.href=link;
  }
  $scope.showhide = function () {
    $scope.cane = false;
  }
});
