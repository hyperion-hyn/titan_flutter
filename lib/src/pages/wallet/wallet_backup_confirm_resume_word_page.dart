import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';

class BackupConfirmResumeWordPage extends StatefulWidget {
  Wallet wallet;
  String mnemonic;

  BackupConfirmResumeWordPage(this.wallet, this.mnemonic);

  @override
  State<StatefulWidget> createState() {
    return _BackupConfirmResumeWordState();
  }
}

class _BackupConfirmResumeWordState extends State<BackupConfirmResumeWordPage> {
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
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    S.of(context).confirm_mnemonic,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    S.of(context).confirm_mnemonic_tips,
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 200),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFB7B7B7)),
                      borderRadius: BorderRadius.circular(16)),
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 3),
                      itemCount: _selectedResumeWords.length,
                      itemBuilder: (BuildContext context, int index) {
                        var word = _selectedResumeWords[index];
                        return InkWell(
                          onTap: () {
                            _selectedWordClick(word);
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: HexColor("#FFB7B7B7")),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text("${index + 1} ${word.text}")),
                        );
                      }),
                ),
                SizedBox(
                  height: 32,
                ),
                GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 3),
                    itemCount: _candidateWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      var candidateWordVo = _candidateWords[index];
                      return InkWell(
                        onTap: () {
                          _candidateWordClick(candidateWordVo);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFFE7E7E7),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            candidateWordVo.text,
                            style: TextStyle(
                                color: candidateWordVo.selected
                                    ? Colors.transparent
                                    : Color(0xFF252525)),
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: 32,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () {
                      var selectedMnemonitc = "";
                      _selectedResumeWords.forEach((word) => selectedMnemonitc =
                          selectedMnemonitc + word.text + " ");

                      logger.i("selectedMnemonitc.trim() $selectedMnemonitc");
                      if (selectedMnemonitc.trim() == widget.mnemonic.trim()) {
                        Fluttertoast.showToast(
                            msg: S.of(context).backup_finish);
                        Routes.popUntilCachedEntryRouteName(context);
                      } else {
                        Fluttertoast.showToast(
                            msg: S.of(context).confirm_mnemonic_incorrect);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            S.of(context).finish,
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
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
