app.controller('HomeCtrl', function ($http, $scope, $rootScope, $window) {

  document.title= "Dashboard | Mergefy";
  // Init
  getUser();
  getUserDocs();

  // Date
  var monthNames = [
    "January", "February", "March",
    "April", "May", "June", "July",
    "August", "September", "October",
    "November", "December"
  ];

  function checkTime(i) {
    return (i < 10) ? "0" + i : i;
  }

  var today = new Date();
  var day = today.getDate();
  var monthIndex = today.getMonth();
  var year = today.getFullYear();
  var min = checkTime(today.getMinutes());
  var hours = checkTime(today.getHours());
  $scope.clock = hours+":"+min;
  $scope.date = day + ' ' + monthNames[monthIndex] + ' ' + year;

  //GET USER
  function getUser(){
    obj = {}; data = {};
    obj.action = "getUser";
    data.user_id = parseInt(window.localStorage['id']);
    obj.data = data;
    $http.post($rootScope.url, [obj]).success(function(ris) {
    	console.log(ris);
    	$scope.user = ris[0].data[0];
    }).error(function(errore) {
    	alert("trovat un errore!", errore);
    })
  }

  // GET USER DOCS
  function getUserDocs(){
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
  }

  // GOTO SINGLE DOC
  $scope.goto = function(id) {
  	var link = "#/doc/"+id;
    window.location.href = $rootScope.urlClient+link;
  }
});
