library rich_text_widget;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

// RichTextWidget
class RichTextWidget extends StatelessWidget {
  final Text defaultText;
  final List<BaseRichText> richTexts;
  final List<TextSpan> _resultRichTexts = [];
  final int maxLines;
  final bool caseSensitive; //Whether to ignore case
  RichTextWidget(this.defaultText,
      {this.richTexts = const [],
      this.caseSensitive = true,
      this.maxLines = 1}) {
    separateText();
  }
  //Split string
  separateText() {
    List<_RichTextModel> result = [];
    String defaultStr = defaultText.data;
    //Find the position of the substring
    richTexts.forEach((richText) {
      RegExp regex = RegExp(richText.data, caseSensitive: this.caseSensitive);
      Iterable<RegExpMatch> matchs = regex.allMatches(defaultStr);
      matchs.forEach((match) {
        int start = match.start;
        int end = match.end;
        if (end > start) {
          result
              .add(_RichTextModel(start: start, end: end, richText: richText));
        }
      });
    });
    if (result.isEmpty) {
      _resultRichTexts
          .add(TextSpan(text: defaultText.data, style: defaultText.style));
      return;
    }
    //Sort by start
    result.sort(([a, b]) => a.start - b.start);

    int start = 0;
    int i = 0;
    // Add the corresponding TextSpan
    while (i < result.length) {
      _RichTextModel model = result[i];
      if (model.start > start) {
        String defaultSubStr = defaultStr.substring(start, model.start);
        _resultRichTexts
            .add(TextSpan(text: defaultSubStr, style: defaultText.style));
      }

      String richSubStr = defaultStr.substring(
          model.start >= start ? model.start : start, model.end);
      _resultRichTexts.add(TextSpan(
        text: richSubStr,
        style: model.richText.style,
        recognizer: model.richText.onTap != null
            ? (TapGestureRecognizer()..onTap = model.richText.onTap)
            : null,
      ));
      start = model.end;
      i++;
      if (i == result.length && start < defaultStr.length) {
        String defaultSubStr = defaultStr.substring(start, defaultStr.length);
        _resultRichTexts
            .add(TextSpan(text: defaultSubStr, style: defaultText.style));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxLines,
      text: TextSpan(children: this._resultRichTexts),
    );
  }
}

// BaseRichText
class BaseRichText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final onTap;
  BaseRichText(this.data, {this.style, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Text(
        this.data,
        style: this.style,
      ),
    );
  }
}

// RichTextModel
class _RichTextModel {
  final int start;
  final int end;
  final BaseRichText richText;
  _RichTextModel({this.start, this.end, this.richText});
}
