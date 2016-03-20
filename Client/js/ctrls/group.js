app.controller('GroupCtrl', function ($scope, $rootScope) {
  $scope.edit = false;
  $scope.editGroup = function() {
    $scope.edit = true;
  };

  $scope.saveChanges = function() {
    $scope.edit = false;
  };
});
