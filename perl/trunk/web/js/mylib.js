function myUploadFile(url, form, callback) {
  form.upload(url, callback, 'json');
}

function myPostFormData(url, form, callback){
  var params = form.serialize();
  $.ajax({
    type: "POST",
    contentType: "text/plain",
    url: url,
    data: {"data":params},
    dataType: "json",
    success: function(data) {
	alert("res:" + data);
    }
  });
}
