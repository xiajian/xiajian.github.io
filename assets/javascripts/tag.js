$(document).ready(function(){
  $("#tags").tagsManager({
    prefilled: ["Apple", "Google"]
  });

  var testtagapi = $("#tag-api").tagsManager();
  $('#addtag').click(function (e) {
    e.preventDefault();
    var tag = "";
    var albet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    for (var i = 0; i < 5; i++)
      tag += albet.charAt(Math.floor(Math.random() * albet.length));
    testtagapi.tagsManager('pushTag', tag);
  });
  $('#removetag').click(function (e) {
    e.preventDefault();
    testtagapi.tagsManager('popTag');
  });
  var tagApi = jQuery("#test-typeahead").tagsManager({
    prefilled: ["Angola", "Laos", "Nepal"]
  });
  $("#test-typeahead").typeahead({
    name: 'countries',
    limit: 15,
    local: [ "Russia", "France", "Ukraine", "Spain", "Sweden", "Norway", "Germany", "Finland", "Poland", "Italy", "United Kingdom", "Romania", "Belarus", "Kazakhstan", "Greece", "Bulgaria", "Iceland", "Hungary", "Portugal", "Serbia", "Austria", "Czech Republic", "Republic of Ireland", "Georgia", "Lithuania", "Latvia", "Croatia", "Bosnia and Herzegovina", "Slovakia", "Estonia", "Denmark", "Netherlands", "Switzerland", "Moldova", "Belgium", "Albania", "Macedonia", "Turkey", "Slovenia", "Montenegro", "Azerbaijan", "Luxembourg", "Andorra", "Malta", "Liechtenstein", "San Marino", "Monaco", "Vatican City", "efe" ]
  }).on('typeahead:selected', function(e,d){
    console.log("test for this function");
    tagApi.tagsManager("pushTag", d.value);
  });
});
