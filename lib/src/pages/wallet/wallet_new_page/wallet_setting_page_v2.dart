import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/pages/atlas_map/atlas/atlas_option_edit_page.dart';
import 'package:titan/src/pages/atlas_map/map3/map3_node_public_widget.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/style/titan_sytle.dart';

typedef TextChangeCallback = void Function(String text);

class WalletSettingPageV2 extends StatefulWidget {
  final Wallet wallet;

  WalletSettingPageV2(this.wallet);

  @override
  State<StatefulWidget> createState() {
    return _WalletSettingPageV2State();
  }
}

class _WalletSettingPageV2State extends State<WalletSettingPageV2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        backgroundColor: Colors.white,
        baseTitle: '钱包身份',
      ),
      body: Container(
        color: DefaultColors.colorf2f2f2,
        child: CustomScrollView(
          slivers: [
            _basicInfoOptions(),
            _addressList(),
            _securityOptions(),
            _pop()
          ],
        ),
      ),
    );
  }

  _basicInfoOptions() {
    return _section(
        '身份信息',
        Column(
          children: [Text('ss')],
        ));
  }

  _addressList() {
    var addressItem = (String chain, String address, List<Color> bgColors) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gradient: LinearGradient(
            colors: bgColors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chain,
                style: TextStyle(
                    fontSize: 16,
                    color: DefaultColors.color333,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                address,
                style: TextStyle(
                    fontSize: 10,
                    color: DefaultColors.color333.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      );
    };

    return _section(
        '钱包主链',
        Column(
          children: [
            addressItem(
              'HYN',
              'sdfsdf',
              [HexColor('#F7D33D'), HexColor('#EDC313')],
            ),
            SizedBox(height: 12),
            addressItem(
              'BTC',
              'sdfsdfassdf',
              [HexColor('#F7A43F'), HexColor('#F7A43F')],
            ),
            SizedBox(height: 12),
            addressItem(
              'ETH',
              'sdfsdf',
              [HexColor('#65AAD0'), HexColor('#65AAD0')],
            )
          ],
        ));
  }

  _securityOptions() {
    return _section(
        '安全',
        Column(
          children: [
            _optionItem(
                title: '显示助记词',
                editCallback: (text) {},
                subContent: '如果你无法访问这个设备，你的资金将无法找回，除非你备份了!',
                warning: '未备份')
          ],
        ));
  }

  _pop() {
    return _section(
        '',
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Center(
            child: Text(
              '退出',
              style: TextStyle(
                color: HexColor('#FF001B'),
              ),
            ),
          ),
        ));
  }

  _section(String title, Widget child) {
    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          children: [
            title.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            color: DefaultColors.color999,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
              color: Colors.white,
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  _optionItem({
    String title,
    String editHint = '',
    String content,
    bool isCanEdit = false,
    TextChangeCallback editCallback,
    TextInputType keyboardType = TextInputType.text,
    bool isAvatar = false,
    String subContent = '',
    String warning = '',
  }) {
    return InkWell(
      splashColor: Colors.blue,
      onTap: () async {
        if (isCanEdit) {
          String text = await Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => OptionEditPage(
                    title: title,
                    content: content,
                    hint: editHint,
                    keyboardType: keyboardType,
                  )));
          if (text.isNotEmpty) {
            setState(() {
              editCallback(text);
            });
          }
          return;
        }
        if (isAvatar) {
          editIconSheet(context, (path) {
            setState(() {
              editCallback(path);
            });
          });
          return;
        }
      },
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: HexColor("#333333"),
                    fontSize: 14,
                  ),
                ),
                if (warning.isNotEmpty)
                  Expanded(
                      child: Row(
                    children: [
                      Spacer(),
                      Image.asset(
                        'res/drawable/ic_warning_triangle_v2.png',
                        width: 15,
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          warning,
                          style: TextStyle(
                            color: HexColor('#E7BB00'),
                          ),
                        ),
                      )
                    ],
                  )),
                isAvatar
                    ? 'path' != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              width: 36,
                              height: 36,
                              child: Image.file(
                                File(content),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: HexColor('#FFDEDEDE'),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          )
                    : content != null
                        ? Text(
                            content,
                            style: TextStyle(
                              color: HexColor("#999999"),
                              fontSize: 14,
                            ),
                          )
                        : Text(
                            editHint,
                            style: TextStyle(
                              color: HexColor("#999999"),
                              fontSize: 14,
                            ),
                          ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right,
                    color: DefaultColors.color999,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              subContent,
              style: TextStyle(color: HexColor("#999999"), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
