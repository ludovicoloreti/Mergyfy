app.controller("ProfileCtrl", function($rootScope, $scope, $http, $window){
  document.title = "Profile | Mergefy";
  data = {};
  action1 = "getUser";
  data.user_id = parseInt(window.localStorage['id']);
  action2 = "getUserDocs";
  action3 = "getUserGroups";
  obj = [
    {
      "action": action1,
      "data": data
    },
    {
      "action": action2,
      "data": data
    },
    {
      "action": action3,
      "data": data
    }
  ];
  console.log(JSON.stringify(obj));
  $http.post($rootScope.url, obj).success(function(res) {
    console.log(res);
    user = res[0].data;
    $scope.docs = res[1].data;
    $scope.groups = res[2].data;
    for (i = 0; i<user.length; i++)
    $scope.user = user[i];
  }).error(function(error) {
    console.log(error, "non vaaaa");
  })

  // switch page on button pression
  $scope.goto = function(page) {
    var link = "#/"+page+"/";
    console.log("clicked. Going to -> "+link)
    window.location.href=link;
  }

  // activate edit view
  $scope.clicked = false;
  $scope.edit = function(){
    $scope.clicked ? $scope.clicked = false : $scope.clicked = true;
  }

  // update user info
  $scope.update = function(user) {
    $scope.clicked = false;
    obj = {};
    data = {};
    obj.action = "updateUser";
    data.id = parseInt(window.localStorage['id']);
    data.name = user.name;
    data.lastname = user.lastname;
    data.mail = user.mail;
    data.born = user.born;
    if(user.content.base64 === undefined){
      data.image_profile = user.image_profile;
    }else{
      data.image_profile = "data:"+user.content.filetype+";base64,"+ user.content.base64;
    }
    obj.data = data;
    console.log(obj);
    $http.post($rootScope.url, [obj]).success(function(res) {
      console.log(res);
    }).error(function(er) {
      console.log(er, "Errore in updateUser");
    });
  }

});
