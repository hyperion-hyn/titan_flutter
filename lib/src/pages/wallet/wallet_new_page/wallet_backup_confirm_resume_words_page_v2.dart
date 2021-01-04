import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class BackupConfirmResumeWordPageV2 extends StatefulWidget {
  final Wallet wallet;
  final String mnemonic;

  BackupConfirmResumeWordPageV2(this.wallet, this.mnemonic);

  @override
  State<StatefulWidget> createState() {
    return _BackupConfirmResumeWordState();
  }
}

class _BackupConfirmResumeWordState
    extends State<BackupConfirmResumeWordPageV2> {
  List<CandidateWordVo> _candidateWords = [];

  List<CandidateWordVo> _selectedResumeWords = [];

  @override
  void initState() {
    initMnemonic();
    super.initState();
  }

  void initMnemonic() {
    logger.i("mnemonic:${widget.mnemonic}");
    _candidateWords = widget.mnemonic
        .split(" ")
        .asMap()
        .map((index, word) =>
            MapEntry(index, CandidateWordVo("$index-$word", word, false)))
        .values
        .toList();

    _candidateWords.shuffle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '确认助记词',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '请按顺序点击助记词，以确认您正确备份。',
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  _selectedCandidateWordsView(),
                  SizedBox(
                    height: 32,
                  ),
                  _candidateWordsView(),
                  SizedBox(
                    height: 32,
                  ),
                  Center(
                    child: ClickOvalButton(
                      S.of(context).next_step,
                      () {
                        var selectedMnemonitc = "";
                        _selectedResumeWords.forEach((word) =>
                            selectedMnemonitc =
                                selectedMnemonitc + word.text + " ");

                        logger.i("selectedMnemonitc.trim() $selectedMnemonitc");
                        if (selectedMnemonitc.trim() ==
                            widget.mnemonic.trim()) {
                          Fluttertoast.showToast(
                              msg: S.of(context).backup_finish);
                          Routes.popUntilCachedEntryRouteName(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: S.of(context).confirm_mnemonic_incorrect);
                        }
                      },
                      width: 300,
                      height: 46,
                      btnColor: [
                        HexColor("#F7D33D"),
                        HexColor("#E7C01A"),
                      ],
                      fontSize: 16,
                      fontColor: DefaultColors.color333,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _selectedCandidateWordsView() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(
            color: DefaultColors.colordedede,
          ),
          color: DefaultColors.colorf6f6f6,
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0),
        child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
            ),
            itemCount: _selectedResumeWords.length,
            itemBuilder: (BuildContext context, int index) {
              var borderRadius = BorderRadius.zero;
              if (index == 0) {
                borderRadius = BorderRadius.only(
                  topLeft: Radius.circular(8),
                );
              } else if (index == 2) {
                borderRadius = BorderRadius.only(
                  topRight: Radius.circular(8),
                );
              } else if (index == _selectedResumeWords.length - 1) {
                borderRadius = BorderRadius.only(
                  bottomRight: Radius.circular(8),
                );
              } else if (index == _selectedResumeWords.length - 3) {
                borderRadius = BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: HexColor('#FFF6F6F6'),
                  border: Border.all(
                    color: HexColor("#FFDEDEDE"),
                    width: 0.5,
                  ),
                  borderRadius: borderRadius,
                ),
                child: Stack(
                  children: [
                    Align(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_selectedResumeWords[index].text}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                    Positioned(
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                            color: DefaultColors.color999, fontSize: 10),
                      ),
                      top: 4,
                      right: 4,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  _candidateWordsView() {
    return Wrap(
      children: List.generate(_candidateWords.length, (index) {
        var candidateWordVo = _candidateWords[index];

        var isShow = !candidateWordVo.selected &&
            !_selectedResumeWords.contains(candidateWordVo);

        if (!isShow) return SizedBox();

        return Padding(
          padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
          child: InkWell(
            onTap: () {
              _candidateWordClick(candidateWordVo);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: HexColor("#FFDEDEDE"),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  candidateWordVo.text,
                  style: TextStyle(
                    color: DefaultColors.color333,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _candidateWordClick(CandidateWordVo word) {
    _candidateWords.forEach((candidateWordVoTemp) {
      if (candidateWordVoTemp == word) {
        if (candidateWordVoTemp.selected == false) {
          candidateWordVoTemp.selected = true;
        }
      }
    });
    if (!_selectedResumeWords.contains(word)) {
      _selectedResumeWords.add(word);
    }
    setState(() {});
  }

  void _selectedWordClick(CandidateWordVo word) {
    if (_selectedResumeWords.contains(word)) {
      _selectedResumeWords.remove(word);
    }
    _candidateWords.forEach((candidateWordVoTemp) {
      if (candidateWordVoTemp == word) {
        if (candidateWordVoTemp.selected == true) {
          candidateWordVoTemp.selected = false;
        }
      }
    });
    setState(() {});
  }
}

class CandidateWordVo {
  String id;
  String text;
  bool selected;

  CandidateWordVo(this.id, this.text, this.selected);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateWordVo &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          selected == other.selected &&
          id == other.id;

  @override
  int get hashCode => text.hashCode ^ selected.hashCode ^ id.hashCode;
}
