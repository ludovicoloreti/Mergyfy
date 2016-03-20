app.controller("GetEventCtrl", function($rootScope, $scope, $http, $window, Evento){
  console.log(Evento.id);
  obj = {};
  data = {};
  obj.action = "getEvent";
  data.event_id = parseInt(Evento.id);
  data.user_id = parseInt(window.localStorage['id']);
  obj.data = data;
  console.log(JSON.stringify(obj));
  $http.post($rootScope.url, [obj]).success(function(res) {
    console.log(res['0'].data);
    ress = res[0].data;
    for (i = 0; i<ress.length; i++)
    $scope.evento = ress[i];
  }).error(function(error) {
    console.log(error, "non vaaaa");
  })
  /* APRI MAPPA */
  $scope.openMap = function(aaa, evento){
    var link = "http://maps.apple.com/maps?q="+evento.latitude+","+evento.longitude;
    $window.location.href = link;
    $window.open(link, "_system", 'location=no');
  }
});
