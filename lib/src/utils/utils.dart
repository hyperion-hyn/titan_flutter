String getExpiredTimeShowTip(int expireTime) {
  var timeLeft = (expireTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  var day = 3600 * 24;
  var hour = 3600;
  var minute = 60;
  if (timeLeft > day) {
    return '${timeLeft ~/ day}天后自动刷新';
  } else if (timeLeft > hour) {
    var hours = timeLeft ~/ hour;
    var minutes = (timeLeft - hours * hour) ~/ 60;
    return '$hours小时$minutes分后自动刷新';
  } else if (timeLeft > minute) {
    var minutes = timeLeft ~/ 60;
    return '$minutes分后自动刷新';
  } else if (timeLeft > 0) {
    return '$timeLeft秒后自动刷新';
  } else {
    return '正在生成加密地址…';
  }
}
