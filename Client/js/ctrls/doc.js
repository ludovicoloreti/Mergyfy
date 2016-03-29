app.controller('DocCtrl', function($scope, $rootScope, $http, Documento){

  // Init variables
  document.title = "Live Doc | Mergefy";
  $scope.toggle = false;
  $scope.clicked= false;
  getPageContent();

  // toggleView: used to toggle the "new note insertion" form.
  $scope.toggleView = function() {
    $scope.toggle = ($scope.toggle) ? false : true;
  };

  // editDoc: used to toggle the possibility to edit the document.
  $scope.editDoc = function(nota) {
    $scope.clicked= ($scope.clicked) ? false: true;
  }

  // ADDNODO
  var obj0 = {};
  var data0 = {};
  var data1 = {};
  $scope.addNodo = function(data0){
    var url = $rootScope.url;
    action0 = "addNoteToDoc";
    data1.type = data0.type;
    data1.title = data0.title;
    if(data1.type == "image"){
      data1.content = "data:"+data0.content.filetype+";base64,"+ data0.content.base64
    }else{
      data1.content = data0.content;
    }
    data1.description = data0.description;
    data1.document_id = parseInt(Documento.id);
    obj0 = [
      {
        action: action0,
        data: data1
      }
    ]
    console.log(obj0);
    $http.post(url, obj0).success(function(risultato) {
      console.log(risultato);
      //window.location.reload(true);
      getPageContent();
    }).error(function(er) {
      console.log(er);
    })
  };


  // GET PAGE CONTENT
  // var obj = {};
  function getPageContent(){
    var data = {};
    action1 = "getDoc";
    action2 = "getDocContent";
    action3 = "getEventNodes";
    data.doc_id = parseInt(Documento.id);

    // request object.
    obj = [
      {
        action: action1,
        data: data
      },
      {
        action: action2,
        data: data
      },
      {
        action: action3,
        data: data
      }
    ]

    $http.post($rootScope.url, obj).success(function(r) {
      console.log(r);
      $scope.doc = r[0].data[0];
      $scope.note = r[1].data;
      $scope.nodi = r[2].data;
    }).error(function(er) {
      console.log(er);
    })
  }

});
