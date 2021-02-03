import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/components/wallet/bloc/bloc.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class WalletBackupConfirmSeedPhrasePageV2 extends StatefulWidget {
  final Wallet wallet;
  final String seedPhrase;

  WalletBackupConfirmSeedPhrasePageV2(this.wallet, this.seedPhrase);

  @override
  State<StatefulWidget> createState() {
    return _BackupConfirmResumeWordState();
  }
}

class _BackupConfirmResumeWordState extends State<WalletBackupConfirmSeedPhrasePageV2> {
  List<CandidateWordVo> _candidateWords = [];
  List<CandidateWordVo> _selectedWords = [];

  @override
  void initState() {
    initSeedPhrase();
    super.initState();
  }

  void initSeedPhrase() {
    _candidateWords = widget.seedPhrase
        .split(" ")
        .asMap()
        .map((index, word) => MapEntry(index, CandidateWordVo("$index-$word", word, false)))
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
        body: Builder(builder: (BuildContext context) {
          return Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _header(),
                          _selectedCandidateWordsView(),
                          _candidateWordsView(),
                        ],
                      ),
                    ),
                  ),
                ),
                _bottomBtn(),
              ],
            ),
          );
        }));
  }

  _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).confirm_seed_phrase,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          S.of(context).confirm_seed_phrase_hint,
          style: TextStyle(
            color: Color(0xFF9B9B9B),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  _selectedCandidateWordsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 200,
        ),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(
              color: DefaultColors.colordedede,
            ),
            color: DefaultColors.colorf6f6f6,
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Wrap(
            children: List.generate(_selectedWords.length, (index) {
              var candidateWordVo = _selectedWords[index];
              return InkWell(
                onTap: () {
                  _unSelectedWord(candidateWordVo);
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: HexColor("#FFDEDEDE"),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Image.asset('res/drawable/ic_transfer_account_detail_fail.png',
                          width: 12, height: 12),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  _candidateWordsView() {
    return Wrap(
      children: List.generate(_candidateWords.length, (index) {
        var candidateWordVo = _candidateWords[index];
        var isShow = !candidateWordVo.selected && !_selectedWords.contains(candidateWordVo);
        if (!isShow) return SizedBox();

        return Padding(
          padding: const EdgeInsets.only(right: 12.0, bottom: 12.0),
          child: InkWell(
            onTap: () {
              _candidateWordClick(candidateWordVo);
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: HexColor("#FFDEDEDE"), width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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

  _bottomBtn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0, top: 22),
      child: ClickOvalButton(
        S.of(context).next_step,
        () async {
          var selectedWords = "";
          _selectedWords.forEach(
            (word) => selectedWords = selectedWords + word.text + " ",
          );
          if (selectedWords.trim() == widget.seedPhrase.trim()) {
            await _confirmBackUp();

            UiUtil.showStateHint(context, true, S.of(context).backup_finish);
            Routes.popUntilCachedEntryRouteName(context);
          } else {
            _showWrongSeedPhraseHint(context);
          }
        },
        width: 300,
        height: 46,
        btnColor: [
          HexColor("#F7D33D"),
          HexColor("#E7C01A"),
        ],
        fontSize: 14,
        fontColor: DefaultColors.color333,
        fontWeight: FontWeight.bold,
      ),
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
    if (!_selectedWords.contains(word)) {
      _selectedWords.add(word);
    }
    setState(() {});
  }

  void _unSelectedWord(CandidateWordVo word) {
    if (_selectedWords.contains(word)) {
      _selectedWords.remove(word);
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

  Future _confirmBackUp() async {
    widget.wallet.walletExpandInfoEntity.isBackup = true;

    BlocProvider.of<WalletCmpBloc>(context).add(UpdateWalletExpandEvent(
      widget.wallet.getEthAccount()?.address,
      widget.wallet.walletExpandInfoEntity,
    ));

    ///延迟等待备份信息已修改，再退出
    await Future.delayed(Duration(milliseconds: 1000), () {});
  }

  _showWrongSeedPhraseHint(BuildContext context) {
    UiUtil.showErrorTopHint(
      context,
      S.of(context).seed_phrase_wrong_order,
    );
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
