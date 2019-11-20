import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/business/wallet/wallet_finish_create_page.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';

class ConfirmResumeWordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ConfirmResumeWordState();
  }
}

class _ConfirmResumeWordState extends State<ConfirmResumeWordPage> {
  List<CandidateWordVo> _candidateWords = [];

  List<String> _selectedResumeWords = [];

  @override
  void initState() {
    initMnemonic();
    super.initState();
  }

  void initMnemonic() {
    logger.i("createWalletMnemonicTemp:$createWalletMnemonicTemp");
    _candidateWords = createWalletMnemonicTemp.split(" ").map((word) => CandidateWordVo(word, false)).toList();

    _candidateWords.shuffle();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "输入恢复短语",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "点击单词，把他们按正确的顺序放在一起",
                    style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  height: 230,
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFB7B7B7)), borderRadius: BorderRadius.circular(16)),
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 3),
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
                                  border: Border.all(color: HexColor("#FFB7B7B7")),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text("${index + 1} ${word}")),
                        );
                      }),
                ),
                SizedBox(
                  height: 36,
                ),
                GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0, childAspectRatio: 3),
                    itemCount: _candidateWords.length,
                    itemBuilder: (BuildContext context, int index) {
                      var candidateWordVo = _candidateWords[index];
                      return InkWell(
                        onTap: () {
                          _candidateWordClick(candidateWordVo.text);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Color(0xFFE7E7E7), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            candidateWordVo.text,
                            style: TextStyle(color: candidateWordVo.selected ? Colors.transparent : Color(0xFF252525)),
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: 36,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 36),
                  constraints: BoxConstraints.expand(height: 48),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    disabledColor: Colors.grey[600],
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white,
                    onPressed: () {
                      _submit();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "继续",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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

  void _candidateWordClick(String word) {
    _candidateWords.forEach((candidateWordVoTemp) {
      if (candidateWordVoTemp.text == word) {
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

  void _selectedWordClick(String word) {
    if (_selectedResumeWords.contains(word)) {
      _selectedResumeWords.remove(word);
    }
    _candidateWords.forEach((candidateWordVoTemp) {
      if (candidateWordVoTemp.text == word) {
        if (candidateWordVoTemp.selected == true) {
          candidateWordVoTemp.selected = false;
        }
      }
    });
    setState(() {});
  }

  Future _submit() async {
    var selectedMnemonitc = "";
    _selectedResumeWords.forEach((word) => selectedMnemonitc = selectedMnemonitc + word + " ");

    logger.i("selectedMnemonitc.trim() $selectedMnemonitc");
    if (selectedMnemonitc.trim() == createWalletMnemonicTemp.trim()) {
      var wallet = await WalletUtil.storeByMnemonic(
          name: createWalletNameTemp, password: createWalletPasswordTemp, mnemonic: createWalletMnemonicTemp.trim());
      Navigator.push(context, MaterialPageRoute(builder: (context) => FinishCreatePage(wallet)));
    } else {
      Fluttertoast.showToast(msg: "您的恢复短语不正确，请重新尝试");
    }
  }
}

class CandidateWordVo {
  String text;
  bool selected;

  CandidateWordVo(this.text, this.selected);
}
