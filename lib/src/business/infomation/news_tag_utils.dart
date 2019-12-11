import 'package:flutter/cupertino.dart';
import 'package:titan/src/business/infomation/news_page.dart';
import 'package:titan/src/business/infomation/wechat_official_page.dart';

class NewsTagUtils {
  static String getNewsTag(Locale locale, int tag) {
    if (locale.languageCode == "zh") {
      if (tag == NewsState.LAST_NEWS_TAG) {
        return NewsTagConsts.ZH_LAST_NEWS_TAG.toString();
      } else if (tag == NewsState.OFFICIAL_ANNOUNCEMENT_TAG) {
        return NewsTagConsts.ZH_OFFICIAL_ANNOUNCEMENT_TAG.toString();
      } else if (tag == NewsState.TUTORIAL_TAG) {
        return NewsTagConsts.ZH_TUTORIAL_TAG.toString();
      } else if (tag == NewsState.VIDEO_TAG) {
        return NewsTagConsts.ZH_VIDEO_TAG.toString();
      } else if (tag == WechatOfficialState.PAPER_TAG) {
        return NewsTagConsts.ZH_KAI_PAPER_TAG.toString();
      } else if (tag == WechatOfficialState.VIDEO_TAG) {
        return NewsTagConsts.ZH_KAI_VIDEO_TAG.toString();
      } else if (tag == WechatOfficialState.AUDIO_TAG) {
        return NewsTagConsts.ZH_KAI_AUDIO_TAG.toString();
      } else if (tag == WechatOfficialState.DOMESTIC_VIDEO) {
        return NewsTagConsts.ZH_KAI_DOMESTIC_VIDEO.toString();
      } else if (tag == WechatOfficialState.FOREIGN_VIDEO) {
        return NewsTagConsts.ZH_KAI_FOREIGN_VIDEO.toString();
      }
    } else {
      if (tag == NewsState.LAST_NEWS_TAG) {
        return NewsTagConsts.EN_LAST_NEWS_TAG.toString();
      } else if (tag == NewsState.OFFICIAL_ANNOUNCEMENT_TAG) {
        return NewsTagConsts.EN_OFFICIAL_ANNOUNCEMENT_TAG.toString();
      } else if (tag == NewsState.TUTORIAL_TAG) {
        return NewsTagConsts.EN_TUTORIAL_TAG.toString();
      } else if (tag == NewsState.VIDEO_TAG) {
        return NewsTagConsts.EN_VIDEO_TAG.toString();
      } else if (tag == WechatOfficialState.PAPER_TAG) {
        return NewsTagConsts.EN_KAI_PAPER_TAG.toString();
      } else if (tag == WechatOfficialState.VIDEO_TAG) {
        return NewsTagConsts.EN_KAI_VIDEO_TAG.toString();
      } else if (tag == WechatOfficialState.AUDIO_TAG) {
        return NewsTagConsts.EN_KAI_AUDIO_TAG.toString();
      }
    }
  }

  static String getCatetory(Locale locale, String category) {
    if (locale.languageCode == "zh") {
      if (category == NewsState.CATEGORY) {
        return NewsCategoryConsts.ZH_HYPERION_CATEGORY;
      } else if (category == WechatOfficialState.CATEGORY) {
        return NewsCategoryConsts.ZH_KAI_CATEGORY;
      }
    } else {
      if (category == NewsState.CATEGORY) {
        return NewsCategoryConsts.EN_HYPERION_CATEGORY;
      } else if (category == WechatOfficialState.CATEGORY) {
        return NewsCategoryConsts.EN_KAI_CATEGORY;
      }
    }
  }
}

class NewsTagConsts {
  static const int ZH_LAST_NEWS_TAG = 26;
  static const int ZH_OFFICIAL_ANNOUNCEMENT_TAG = 22;
  static const int ZH_TUTORIAL_TAG = 30;
  static const int ZH_VIDEO_TAG = 48;

  static const int ZH_KAI_PAPER_TAG = 39;
  static const int ZH_KAI_VIDEO_TAG = 34;
  static const int ZH_KAI_AUDIO_TAG = 52;

  static const int ZH_KAI_DOMESTIC_VIDEO = 43;
  static const int ZH_KAI_FOREIGN_VIDEO = 45;

  static const int EN_LAST_NEWS_TAG = 28;
  static const int EN_OFFICIAL_ANNOUNCEMENT_TAG = 24;
  static const int EN_TUTORIAL_TAG = 32;
  static const int EN_VIDEO_TAG = 50;

  static const int EN_KAI_PAPER_TAG = 42;
  static const int EN_KAI_VIDEO_TAG = 34;
  static const int EN_KAI_AUDIO_TAG = 54;

  static const int KO_LAST_NEWS_TAG = 71;
  static const int KO_OFFICIAL_ANNOUNCEMENT_TAG = 77;
  static const int KO_TUTORIAL_TAG = 69;
  static const int KO_VIDEO_TAG = 75;

//  static const int KO_KAI_PAPER_TAG = 42;
//  static const int KO_KAI_VIDEO_TAG = 34;
//  static const int KO_KAI_AUDIO_TAG = 54;
}

class NewsCategoryConsts {
  static const String ZH_HYPERION_CATEGORY = "1";
  static const String ZH_KAI_CATEGORY = "3";

  static const String EN_HYPERION_CATEGORY = "9";
  static const String EN_KAI_CATEGORY = "12";
}
