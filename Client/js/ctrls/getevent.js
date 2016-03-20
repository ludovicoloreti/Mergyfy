app.controller("GetEventCtrl", function($rootScope, $scope, $http, $window, Evento){
  console.log(Evento.id);
  data1 = {}; data2 = {}
  action1 = "getEvent";
  data1.event_id = parseInt(Evento.id);
  data1.user_id = parseInt(window.localStorage['id']);
  data10 = data1;
  action2 = "getEventPartecipants";
  data2.event_id = parseInt(Evento.id);
  data20 = data2;
  obj = [
    {
      "action": action1,
      "data": data10
    },
    {
      "action": action2,
      "data": data20
    }
  ];
  console.log(JSON.stringify(obj));

  $http.post($rootScope.url, obj).success(function(res) {
    resGetEvent = res[0].data;
    $scope.partecipanti = res[1].data;
    console.log(res[1].data)
    for (i = 0; i<resGetEvent.length; i++)
    $scope.evento = resGetEvent[i];
  }).error(function(error) {
    console.log(error, "non vaaaa");
  })

  /* APRI MAPPA */
  $scope.openMap = function(aaa, evento){
    var link = "http://maps.apple.com/maps?q="+evento.latitude+","+evento.longitude;
    $window.location.href = link;
    $window.open(link, "_system", 'location=no');
  }

  // crea documento
  $scope.createDoc = function(){
    // da sistemare
    obj = {};
    obj.action = "createDoc";
    data = {};
    data.creator_id = parseInt(window.localStorage['id']);
    data.name = "Nome evento"; // sistemare evento
    data.event_id = parseInt(Evento.id);
    data.visibility_type = '1';
    obj.data = data;
    console.log(obj);
    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
      var link = "#/doc";
      console.log("clicked on a group link. Going to -> " + link)
      window.location.href = link;
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })

  }
});
