app.controller('DocCtrl', function($scope, $rootScope, $http /*DOC*/){
  //console.log(Doc.id);
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
    var url = $rootScope.url;
    obj.action = "addNoteToDoc";
    data.type = data.type;
    data.title = data.title;
    data.content = data.content;
    data.description = data.description;
    obj.data = data;
    $http.post(url, obj).success(function(r) {
      console.log(r);
    }).error(function(er) {
      console.log(er);
    })
  };

  var obj = {};
  var data = {};
  obj.action = "getDoc";
  data.doc_id = 1;
  obj.data = data;
  $http.post($rootScope.url, [obj]).success(function(r) {
    console.log(r);
  }).error(function(er) {
    console.log(er);
  })
});
