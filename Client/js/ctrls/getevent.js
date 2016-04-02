app.controller("GetEventCtrl", function($rootScope, $scope, $http, $window, Evento){
  document.title = "Event | Mergefy";


  getAll();
  //TODO MI MARCA SOLO GLI EVENTI VICINI.
  function getAll(){
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

    $http.post($rootScope.url, obj).success(function(res) {
      console.log(res)
      resGetEvent = res[0].data;
      $scope.partecipanti = res[1].data;
      for (i = 0; i<resGetEvent.length; i++)
      $scope.evento = resGetEvent[i];
      if (typeof $scope.evento === "undefined") {
        console.log("Nessun risultato, non puoi vedere questo evento")
        //window.location.href=$rootScope.urlClient+"index.html#/events";
      } else {
        console.log("Hai il diritto di vedere questo evento");

      }
    }).error(function(error) {
      console.log(error, "Errore durante la comunicazione");
    })
  }



  $scope.updatePartecipationStatus = function(status){
    var request = {};
    var data = {};
    request.action = "updatePartecipationStatus";
    data.event_id = parseInt(Evento.id);
    data.user_id = parseInt(window.localStorage['id']);
    data.status = status;
    request.data = data;
    $http.post($rootScope.url, [request]).success(function(res) {
      console.log(res);
      getAll();
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })
  }
  /* APRI MAPPA */
  $scope.openMap = function(aaa, evento){
    var link = "http://maps.apple.com/maps?q="+evento.latitude+","+evento.longitude;
    $window.location.href = link;
    $window.open(link, "_system", 'location=no');
  }

  // crea documento
  $scope.createDoc = function(nomeEvento){
    // da sistemare
    obj = {};
    obj.action = "createDoc";
    data = {};
    data.creator_id = parseInt(window.localStorage['id']);
    data.name = nomeEvento;
    data.event_id = parseInt(Evento.id);
    data.visibility_type = '1';
    obj.data = data;
    console.log(obj);
    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
      var link = "#/doc/"+res[0].data[0].lastid;
      // console.log(link)
      window.location.href = $rootScope.urlClient+link;
    }).error(function(error) {
      console.log(error, "non vaaaa");
    })

  }
});
