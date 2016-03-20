app.controller('EventCtrl', function($rootScope, $scope, $http,$window){

  console.log("ciao");
  $scope.custom = true;
  $scope.toggleCustom = function() {
    $scope.custom = $scope.custom === false ? true: false;
  };

  // https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyCmhQc5fBRF5OUDFAawn9L0ZBolUlSw_8k
  // bisogna usare questo circa


  /* invita gruppi */
  var linkPerLaGet = $rootScope.url+"?user_id="+window.localStorage['id'];
  $http.get(linkPerLaGet).success(function(r) {
    $scope.gruppi = r;
  }).error(function(err) {
    console.log(err);
    $scope.gruppi = [
      {
        nome: "Errore",
        id: 1
      },
      {
        nome: "Nella",
        id: 2
      },
      {
        nome: "Get",
        id: 3
      }
    ];
  })





  /*
  POST createEvent
  */

  // per verifiche by ludo -> da cancellare!!!
  // var createEventLinkToPost = "file.json";
  // $http.get(createEventLinkToPost).success(function(data) {
  //   console.log(data);
  // })
  // fine verifiche da cancellareeeeeeee
  // $scope.vm = {};
  // var adesso = new Date();
  // year = adesso.getFullYear();
  // month = adesso.getMonth();
  // monthh = month+1;
  // day = adesso.getDate();
  // console.log(year, month, monthh, day);
  // $scope.vm.dataStart = new Date(year, month, day);
  // $scope.vm.dataEnd = new Date(year, monthh, day);
  $scope.createEvent = function(dataObj) {
    console.log("createEvent")
    if (!angular.isUndefined(dataObj)) {
      count = 0;
      angular.forEach(dataObj, function(v, k) {
        count++;
      });
      if ((count===10)||(count===11)||(count===13)) {
        console.log(JSON.stringify(dataObj))
        // GEOCODING start
        var urlToGmaps = "http://maps.google.com/maps/api/geocode/json?address="+dataObj.address+"+"+dataObj.city+"&sensor=false";
        $http.get(urlToGmaps).success(function (data) {
          console.log(data.results[0].geometry.location);
          // GEOCODING end
          dataObj.lat = data.results[0].geometry.location.lat;
          dataObj.lng = data.results[0].geometry.location.lng;
          // faccio la post
          var createEventLinkToPost = "http://localhost:8888/MDEF/Server/handler.php?action=addEvent&model=event";
          $http.post(createEventLinkToPost, dataObj).success(function(data, status, headers, config) {
            console.info(JSON.stringify(data));
            $scope.data = data;
          }).error(function(data, status, headers, config) {
            console.log(data, config);
            alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
          });
        }).error(function (data) {
          alert("Errore nell'invio della POST: " + JSON.stringify({data: data}));
        });


      }
      else {
        console.log("Errore conteggio dati","Non hai compilato tutti i campi!")
      }
    } else {
      console.log("Errore nell'invio del form","Il form risulta essere vuoto.")
    }
  }

});
