app.controller('GroupCtrl', function ($scope, $http, $location, $rootScope,Gruppo) {
  if (parseInt(Gruppo.id)) {
    $scope.cane = true;
  }
  $scope.showhide = function () {
    $scope.cane = false;
  }
  $scope.edit = false;

  gruppo = {}
  $scope.editGroup = function() {
    $scope.edit = true;

  };

  $scope.saveChanges = function(gruppo) {
    $scope.edit = false;

    obj = {}; data = {};
    obj.action = "updateGroup";
    data.group_id = parseInt(gruppo.id);
    data.name = gruppo.name;
    if (gruppo.image == null) {
      data.image = "null";
    } else {
      data.image = gruppo.image;
    }
    data.description = gruppo.description;
    obj.data = data;
    console.log(obj)
    $http.post($rootScope.url, [obj]).success(function(r) {
      console.log(r)
    }).error(function(err) {
      console.log(err, "non va");
    })
  };

  obj = {}; data = {}; data1 = {};
  action = "getUserGroups";
  data.user_id = parseInt(window.localStorage['id']);
  data11 = data;
  action1 = "getGroupInfo";
  data1.group_id = parseInt(Gruppo.id);
  data10 = data1;
  action2 = "getGroupMembers";
  obj = [
    {
      "action": action,
      "data": data11
    },
    {
      "action": action1,
      "data": data10
    },
    {
      "action": action2,
      "data": data10
    }
  ];
  console.log(JSON.stringify(obj));
  $http.post($rootScope.url, obj).success(function(res) {
    console.log(res);
    $scope.groups = res[0].data;
    rr = res[1].data;
    for (i = 0; i<rr.length; i++)
    $scope.gruppo = rr[i];
    $scope.membri = res[2].data;
  }).error(function(err) {
    console.log(err, "non vaaaa");
  })
  $scope.view = function(id) {
    var link = "#/group/"+id;
    console.log("clicked on a group link. Going to -> "+link)
    window.location.href=link;
  }
});
