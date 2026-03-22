KindEditor.plugin('word', function (K) {
    // 点击图标时执行
	var name = 'word';
    editor.clickToolbar(name, function () {
		let blackstr = countBlackword();
        editor.insertHtml(blackstr);
    });
});

function countBlackword() {
  //editor.sync();
  const str = editor.html();
  const subStr = "blackword";
  // 将子字符串转换为正则表达式，并添加全局搜索标志
  const nums = ["①","②","③","④","⑤","⑥","⑦","⑧","⑨"];
  const regex = new RegExp(subStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
  const n = (str.match(regex) || []).length;
  // 使用match方法查找所有匹配，然后返回数量
  let blackstr = '<input type="text"  class="blackword" value="'+nums[n]+'" readonly="true"/>';
  return blackstr
}