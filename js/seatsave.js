var docurl = document.URL;
var ipurl = docurl.substring(0, docurl.lastIndexOf("/"));

function SaveSeats(hid, collects) {
    var saveurl = ipurl + "/saveseat.ashx";
    $.ajax({
        type: "POST",
        url: saveurl,
        cache: false,
        data: { Hid: hid, Collects: collects },
        dataType: "html",
        success: function (data) {
            if (data.toString() == "1") {
                $('#msg').html("当前布置提交成功!");
            }
            else {
                $('#msg').html("当前布置提交失败!");
            }
        }
    });
}