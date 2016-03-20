app.controller('DocCtrl', function($scope, $rootScope, $http){
  $scope.toggle = false;
  $scope.toggleView = function() {
    $scope.toggle = ($scope.toggle) ? false : true;
  };

  $scope.title= "";
  $scope.text= "";

  var obj = {};
  var data = {};
  console.log(obj)
  $scope.addNodo = function(data){
    console.log(data)
    var url = $rootScope.url+"?action=createNote&model=lol";
    obj.type = data.type;
    obj.title = data.title;
    obj.content = data.content;
    obj.description = data.description;
    obj.docid = "1";
    $http.post(url, obj).success(function(r) {
      console.log(r);
    }).error(function(er) {
      console.log(er);
    })
  };
});
