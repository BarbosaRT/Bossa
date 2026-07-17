String zerosBeforeDuration(Duration duration) {
  String d = duration.toString().split('.')[0];
  String replacement = '';
  for (var number in d.split('')) {
    if (number != '0' && number != ':') {
      break;
    }
    replacement += number;
  }
  return replacement;
}

String durationFormatter(Duration duration, {int length = 4}) {
  length = length < 4 ? 4 : length;

  String durationString = duration.toString().split('.')[0];
  String replacement = zerosBeforeDuration(duration);
  String replacedString = durationString.replaceFirst(replacement, '');

  if (length > replacedString.length) {
    replacement = '';
    durationString = duration.toString().split('.')[0];
    int diference = durationString.length - length;
    for (var number in durationString.split('')) {
      if (number != '0' && number != ':' || diference == 0) {
        break;
      }
      replacement += number;
      diference -= 1;
    }
  }

  return durationString.replaceFirst(replacement, '');
}
