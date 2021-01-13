import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_state.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/pages/red_pocket/rp_share_open_page.dart';
import 'package:titan/src/pages/red_pocket/rp_share_type_page.dart';

class RpFloatingWidget extends StatefulWidget {
  final int actionType;
  RpFloatingWidget({this.actionType});

  @override
  _RpFloatingWidgetState createState() => _RpFloatingWidgetState();
}

class _RpFloatingWidgetState extends BaseState<RpFloatingWidget> {
  Offset offset = Offset(10, 0);

  Offset _calOffset(Size size, Offset offset, Offset nextOffset) {
    double dx = 0;
    //水平方向偏移量不能小于0不能大于屏幕最大宽度
    if (offset.dx + nextOffset.dx <= 0) {
      dx = 10;
    } else if (offset.dx + nextOffset.dx >= (size.width - 80)) {
      dx = size.width - 80;
    } else {
      dx = offset.dx + nextOffset.dx;
    }

    double dy = 0;
    //垂直方向偏移量不能小于0不能大于屏幕最大高度
    if (offset.dy + nextOffset.dy <= 0) {
      dy = 0;
    } else if (offset.dy + nextOffset.dy >= (size.height - 150)) {
      dy = size.height - 150;
      //print("[$runtimeType] 1, dy:$dy");
    } else {
      dy = offset.dy + nextOffset.dy;
      //print("[$runtimeType] 2, dy:$dy");
    }

    //print("[$runtimeType] size:${size.toString()}, dy:$dy");

    return Offset(
      dx,
      dy,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void onCreated() {
    super.onCreated();

    var size = MediaQuery.of(context).size;
    offset = Offset(size.width - 80, size.height * 0.5);

    if (widget.actionType == -1) {
      offset = Offset(size.width - 80, size.height * 0.65);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (detail) {
          setState(() {
            offset = _calOffset(MediaQuery.of(context).size, offset, detail.delta);
          });
        },
        onPanEnd: (detail) {},
        child: _floatingWidget(),
      ),
    );
  }

  Widget _floatingWidget() {
    return SizedBox(
      width: 80,
      height: 80,
      child: IconButton(
        onPressed: _navToShareRp,
        icon: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(
              'res/drawable/rp_share_floating.png',
              // width: 80,
              // height: 69,
              fit: BoxFit.cover,
              // color: HexColor('#FF1F81FF'),
            ),
            Positioned(
              top: 30,
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '攒好友',
                    style: TextStyle(
                      color: HexColor('#FFFFFF'),
                      fontWeight: FontWeight.w500,
                      fontSize: 6,
                    ),
                  ),
                  Text(
                    widget.actionType == -1 ? '开红包' : '发红包',
                    style: TextStyle(
                      color: HexColor('#FFFFFF'),
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _navToShareRp() {
    var activeWallet = WalletInheritedModel.of(context)?.activatedWallet;

    if (widget.actionType == -1) {
      var _address  = activeWallet.wallet.getAtlasAccount().address;
      var _walletName = activeWallet.wallet.keystore.name;
      showShareRpOpenDialog(context:context, id:'9LLQ42', address:_address, walletName: _walletName,);
      return;
    }


    if (activeWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RpShareTypePage(),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: S.of(context).create_or_import_wallet_first);
    }
  }
}
