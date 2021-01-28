import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/config/application.dart';
import 'package:titan/src/plugins/wallet/wallet.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/routes/fluro_convert_utils.dart';
import 'package:titan/src/routes/routes.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/widget/loading_button/click_oval_button.dart';

class AppLockWalletNotBackUpDialog extends StatefulWidget {
  final List<Wallet> walletList;

  AppLockWalletNotBackUpDialog(this.walletList);

  @override
  State<StatefulWidget> createState() {
    return _AppLockWalletNotBackUpDialogState();
  }
}

class _AppLockWalletNotBackUpDialogState extends State<AppLockWalletNotBackUpDialog> {
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
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
            ),
            Image.asset(
              'res/drawable/img_safe_lock_edit.png',
              width: 80,
              height: 80,
            ),
            Text(
              '设置应用锁',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 14,
              ),
              child: Text(
                '应用锁密码忘记后只有助记词可恢复钱包身份，请务必确保所有钱包助记词已备份！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HexColor('#666666'),
                ),
              ),
            ),
            _walletList(),
          ],
        ),
        Positioned(
          child: InkWell(
            child: Image.asset(
              'res/drawable/ic_close.png',
              width: 16,
              height: 16,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          left: 24,
          top: 24,
        )
      ],
    );
  }

  _walletList() {
    List<Widget> walletList = List.generate(widget.walletList.length, (index) {
      var name = widget.walletList[index].keystore.name;
      var address = shortBlockChainAddress(WalletUtil.ethAddressToBech32Address(
        widget.walletList[index].getEthAccount().address,
      ));
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 36.0,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(
              '$name  ($address)',
              style: TextStyle(
                color: DefaultColors.color999,
              ),
            )),
            ClickOvalButton(
              '去备份',
              () {
                Navigator.pop(context);
                var walletStr = FluroConvertUtils.object2string(widget.walletList[index].toJson());
                Application.router.navigateTo(
                  context,
                  Routes.wallet_setting_wallet_backup_notice +
                      '?entryRouteName=${Uri.encodeComponent(Routes.wallet_setting)}&walletStr=$walletStr',
                );
              },
              width: 50,
              height: 22,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontColor: Colors.black,
              btnColor: [
                HexColor("#F7D33D"),
                HexColor("#E7C01A"),
              ],
            )
          ],
        ),
      );
    });
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 36.0,
                  bottom: 8.0,
                ),
                child: Text(
                  '未备份钱包:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: walletList,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
