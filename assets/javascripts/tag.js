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
});
