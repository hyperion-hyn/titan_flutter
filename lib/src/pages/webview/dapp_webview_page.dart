import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:titan/generated/l10n.dart' as trans;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/generated/l10n.dart';
import 'package:titan/src/basic/utils/hex_color.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/config/consts.dart';
import 'package:titan/src/global.dart';
import 'package:titan/src/pages/wallet/model/wallet_send_dialog_util.dart';
import 'package:titan/src/plugins/titan_plugin.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/log_util.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/utils/utils.dart';
import 'package:titan/src/pages/app_tabbar/app_tabbar_page.dart';
import 'package:titan/src/widget/widget_shot.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

import 'dapp_authorization_dialog_page.dart';
import 'dapp_send_dialog_page.dart';
import 'package:titan/src/basic/widget/base_state.dart';

class DAppWebViewPage extends StatefulWidget {
  final String initUrl;
  final String title;
  final bool isShowAppBar;
  int defaultCoin;

  DAppWebViewPage({
    this.initUrl,
    this.title = '',
    this.isShowAppBar = true,
    this.defaultCoin = CoinType.HB_HT,
  });

  @override
  State<StatefulWidget> createState() {
    return DAppWebViewPageState();
  }
}

class DAppWebViewPageState extends BaseState<DAppWebViewPage> with WidgetsBindingObserver {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  String title;
  bool isLoading = true;

  Function onBackPress;
  Function onForwardPress;
  var walletAddress;
  var rpcUrl;
  var chainId;

  int get selectCoinType => widget.defaultCoin;

  set setSelectCoinType(int selectCoin) {
    widget.defaultCoin = selectCoin;
  }

  bool hadShowEnableDialog = false;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        await Future.delayed(Duration(milliseconds: 500),(){});
        var clipStr = await TitanPlugin.getClipboardData();
        await Clipboard.setData(ClipboardData(text: clipStr));
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onCreated() async {

    super.onCreated();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (webView != null) {
          if (await webView.canGoBack()) {
            webView.goBack();
            return false;
          }
        }

        return true;
      },
      child: Scaffold(
        appBar: widget.isShowAppBar
            ? BaseAppBar(
                baseTitle: title ?? widget.title,
                actions: <Widget>[
                  InkWell(
                      onTap: () {
                        _showNetworkSelect();
                      },
                      child: Center(
                          child: Container(
                        padding: const EdgeInsets.only(left: 12.0, right: 12, top: 4, bottom: 4),
                        decoration: BoxDecoration(
                            color: HexColor("#F6F6F6"),
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        child: Row(
                          children: [
                            Text(
                              "${getCoinTypeStr()}",
                              style: TextStyles.textC333S14,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Image.asset(
                              "res/drawable/wallet_gas_down.png",
                              width: 8,
                              color: DefaultColors.color333,
                            )
                          ],
                        ),
                      ))),
                  PopupMenuButton(
                    offset: Offset(0, 45),
                    icon: Icon(Icons.more_horiz),
                    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                      PopupMenuItem(
                        value: 1,
                        child: Center(
                            child: Text(
                          S.of(context).reload,
                          style: TextStyle(color: DefaultColors.color333, fontSize: 14),
                        )),
                      ),
                      PopupMenuItem(
                        height: 1,
                        child: Divider(
                          height: 1,
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Center(
                            child: Text(
                          S.of(context).copy_link,
                          style: TextStyle(color: DefaultColors.color333, fontSize: 14),
                        )),
                      ),
                    ],
                    onSelected: (result) async {
                      if (result == 1) {
                        webView.reload();
                        await Future.delayed(Duration(milliseconds: 3000), () {
                          callbackToJS(webView);
                        });
                      } else if (result == 2) {
                        Clipboard.setData(ClipboardData(text: widget.initUrl));
                        UiUtil.toast(trans.S.of(context).copyed);
                      }
                    },
                  ),
                ],
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (isLoading)
                SizedBox(
                    height: 2,
                    child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
              Expanded(
                child: _body(),
              ),
              if (onBackPress != null && onForwardPress != null)
                Column(
                  children: <Widget>[
                    Divider(
                      height: 0,
                    ),
                    Container(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: onBackPress,
                            icon: Icon(Icons.chevron_left),
                            disabledColor: Colors.grey[200],
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          IconButton(
                            onPressed: onForwardPress,
                            icon: Icon(Icons.chevron_right),
                            disabledColor: Colors.grey[200],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _body() {
    walletAddress =
        WalletInheritedModel.of(context).activatedWallet.wallet.getEthAccount().address ?? "";
    rpcUrl = WalletUtil.getRpcApiByCoinType(selectCoinType) ?? "";
    chainId =
        WalletInheritedModel.of(context).activatedWallet.wallet.getChainId(selectCoinType) ?? "";

    return InAppWebView(
      initialUrl: widget.initUrl,
      initialHeaders: {},
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(useShouldInterceptRequest: true),
          dappOptions: DappOptions(walletAddress, rpcUrl, chainId,AppTabBarPage.initStr,AppTabBarPage.libraryStr)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;

        initDappJsHandle(controller);
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        isLoading = false;
        print("onLoadStop $url");

        if (hadShowEnableDialog) {
          return;
        }
        hadShowEnableDialog = true;
        DAppAuthorizationDialogEntity entity = DAppAuthorizationDialogEntity(
          title: S.of(context).visit_instructions,
          dAppName: widget.title,
        );
        var authorizaResult = await showDAppAuthorizationDialog(
          context: context,
          entity: entity,
        );
        if (authorizaResult == null || !authorizaResult) {
          Navigator.of(context).pop();
        }

        setState(() {
          this.url = url;
        });

        updateBackOrForward();
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        setState(() {
          this.progress = progress / 100;
          //print('[inapp] --> webView, progress:${progress}');
        });
      },
      onConsoleMessage: (_, message) {
        if (message.messageLevel == ConsoleMessageLevel.DEBUG) {
          logger.d(message.message);
        } else if (message.messageLevel == ConsoleMessageLevel.TIP) {
          logger.v(message.message);
        } else if (message.messageLevel == ConsoleMessageLevel.LOG) {
          //logger.i(message.message);
        } else if (message.messageLevel == ConsoleMessageLevel.WARNING) {
          logger.w(message.message);
        } else if (message.messageLevel == ConsoleMessageLevel.ERROR) {
          logger.e(message.message);
        }
      },
      onLoadError: (InAppWebViewController controller, String url, int code,
          String message){
        LogUtil.uploadExceptionStr("addr: $walletAddress url: $url message: $message","dapp error");
      },
    );
  }

  void _showNetworkSelect() {
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 80,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(S.of(context).choose_network, style: TextStyles.textC333S14bold),
            ),
          ),
          
          // networkItem("res/drawable/ic_token_hyn.png", "Atlas", CoinType.HYN_ATLAS),
          networkItem('res/drawable/ic_token_eth.png', "Ethereum", CoinType.ETHEREUM),
          networkItem("res/drawable/ic_token_ht.png", "Heco", CoinType.HB_HT),
        ],
      ),
    );
  }

  Widget networkItem(String imagePath, String networkName, int coinType) {
    return InkWell(
      onTap: () async {
        setSelectCoinType = coinType;
        await updateNetwork();
        setState(() {});
        Future.delayed(Duration(milliseconds: 1000), () {
          webView.reload();
        });
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 10, top: 15, bottom: 15),
                child: Image.asset(
                  imagePath,
                  width: 40,
                  height: 40,
                ),
              ),
              Text(
                networkName,
                style: TextStyles.textC333S16bold,
              )
            ],
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          )
        ],
      ),
    );
  }

  void initDappJsHandle(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
        handlerName: "enable",
        callback: (data) async {
          /*if (hadEnable) {
            return;
          }
          DAppAuthorizationDialogEntity entity = DAppAuthorizationDialogEntity(
            title: S.of(context).visit_instructions,
            dAppName: widget.title,
          );
          var authorizaResult = await showDAppAuthorizationDialog(
            context: context,
            entity: entity,
          );
          if (authorizaResult == null || !authorizaResult) {
            Navigator.of(context).pop();
          } else {
            hadEnable = true;
          }*/
        });

    controller.addJavaScriptHandler(
        handlerName: "processTransaction",
        callback: (data) async {
          int callbackId = data[0];
          try {
            String to = data[1] == null ? null : data[1].toString();
            BigInt value = data[2] == null ? BigInt.zero : BigInt.parse(data[2].toString());
            int nonce = data[3] == null || data[3] == -1 ? null : int.parse(data[3].toString());
            int gasLimit = data[4] == null ? null : int.parse(data[4].toString());
            BigInt gasPrice = data[5] == null ? null : BigInt.parse(data[5].toString());
            Uint8List _data = data[6] == null ? null : hexToBytes(data[6]);

            if(gasPrice == null && selectCoinType == CoinType.ETHEREUM){
              gasPrice = await WalletUtil.ethGasPrice(selectCoinType);
            }

            showSendDialogDApp(
                context: context,
                to: to,
                value: value,
                valueUnit: getCoinTypeSymbol(),
                gasValue: gasLimit,
                gasUnit: getCoinTypeSymbol(),
                gasPrice: gasPrice,
                coinType: selectCoinType,
                confirmAction: (String pswStr, BigInt gasPriceCallback) async {

                  var wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                  var signed = await wallet.sendDappTransaction(
                    selectCoinType,
                    password: pswStr,
                    toAddress: to,
                    value: value,
                    nonce: nonce,
                    gasPrice: BigInt.parse(gasPriceCallback.toString()),
                    gasLimit: gasLimit,
                    data: _data,
                  );
                  callbackToJS(controller, callbackId: callbackId, value: signed);

                  Navigator.of(context).pop();
                  return true;
                });
          } catch (e, stack) {
            callbackToJS(controller, callbackId: callbackId, error: e.toString());
            LogUtil.toastException(e,stack: stack);
          }
        });

    controller.addJavaScriptHandler(
        handlerName: "signMessage",
        callback: (data) {
          flutterCallToWeb(
              controller, "executeCallback(${data[0]}, null, \"hello callback native\")");
        });

    controller.addJavaScriptHandler(
        handlerName: "signPersonalMessage",
        callback: (data) {
        });

    controller.addJavaScriptHandler(
        handlerName: "signTypedMessage",
        callback: (data) {
          int callbackId = data[0];
          callbackToJS(controller, callbackId: callbackId, value: 'demo back');
        });

    controller.addJavaScriptHandler(
        handlerName: "ethCall",
        callback: (data) async {
          int callbackId = data[0];
          try {
            String recipient = data[1];
            String payload = data[2];
            final client = WalletUtil.getWeb3Client(selectCoinType);
            var wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
            var from = wallet.getEthAccount().address;
            var bytes = hexToBytes(payload);

            var ret = await client.callRaw(
                sender: EthereumAddress.fromHex(from),
                contract: EthereumAddress.fromHex(recipient),
                data: bytes);
            callbackToJS(controller, callbackId: callbackId, value: ret);
          } catch (e) {
            callbackToJS(controller, callbackId: callbackId, error: e.toString());
          }
        });

    /***
     * 重写签名调用
     * 一般WC才会用到
     * ***/
    controller.addJavaScriptHandler(
        handlerName: "processSignTransaction",
        callback: (data) async {
          int callbackId = data[0];
          try {
            String to = data[1] == null ? null : data[1].toString();
            BigInt value = data[2] == null ? BigInt.zero : BigInt.parse(data[2].toString());
            int nonce = data[3] == null || data[3] == -1 ? null : int.parse(data[3].toString());
            int gasLimit = data[4] == null ? null : int.parse(data[4].toString());
            BigInt gasPrice = data[5] == null ? null : BigInt.parse(data[5].toString());
            Uint8List _data = data[6] == null ? null : hexToBytes(data[6]);

            if(gasPrice == null && selectCoinType == CoinType.ETHEREUM){
              gasPrice = await WalletUtil.ethGasPrice(selectCoinType);
            }

            showSendDialogDApp(
                context: context,
                to: to,
                value: value,
                valueUnit: getCoinTypeSymbol(),
                gasValue: gasLimit,
                gasUnit: getCoinTypeSymbol(),
                gasPrice: gasPrice,
                coinType: selectCoinType,
                confirmAction: (String pswStr, BigInt gasPriceCallback) async {

                  var wallet = WalletInheritedModel.of(context).activatedWallet.wallet;
                  var signed = await wallet.signTransaction(
                    selectCoinType,
                    password: pswStr,
                    toAddress: to,
                    value: value,
                    nonce: nonce,
                    gasPrice: BigInt.parse(gasPriceCallback.toString()),
                    gasLimit: gasLimit,
                    data: _data,
                  );
                  callbackToJS(controller, callbackId: callbackId, value: signed);

                  Navigator.of(context).pop();
                  return true;
                });
          } catch (e, stack) {
            callbackToJS(controller, callbackId: callbackId, error: e.toString());
            LogUtil.toastException(e,stack: stack);
          }
        });
  }

  dynamic callbackToJS(InAppWebViewController controller,
      {@required int callbackId, String value, String error}) async {
    var errorStr = error == null ? 'null' : '\"' + error + '\"';
    var valueStr = value == null ? 'null' : '\"' + value + '\"';
    var source = '''
    executeCallback($callbackId, $errorStr, $valueStr)
    ''';

    return flutterCallToWeb(controller, source);
  }

  dynamic flutterCallToWeb(InAppWebViewController controller, String source) async {
    return await controller.evaluateJavascript(source: source);
  }

  void updateBackOrForward() async {
    if (await webView?.canGoBack() == true) {
      onBackPress = () {
        webView.goBack();
      };
    } else {
      onBackPress = null;
    }

    if (await webView?.canGoForward() == true) {
      onForwardPress = () {
        webView.goForward();
      };
    } else {
      onForwardPress = null;
    }

    setState(() {});
  }

  String getCoinTypeStr() {
    switch (selectCoinType) {
      case CoinType.HYN_ATLAS:
        return "ATLAS";
      case CoinType.ETHEREUM:
        return "ETH";
      case CoinType.HB_HT:
        return "HECO";
    }
    return "";
  }

  String getCoinTypeSymbol() {
    switch (selectCoinType) {
      case CoinType.HYN_ATLAS:
        return "HYN";
      case CoinType.ETHEREUM:
        return "ETH";
      case CoinType.HB_HT:
        return "HT";
    }
    return "";
  }

  updateNetwork() async {
    walletAddress =
        WalletInheritedModel.of(context).activatedWallet.wallet.getEthAccount().address ?? "";
    rpcUrl = WalletUtil.getRpcApiByCoinType(selectCoinType) ?? "";
    chainId =
        WalletInheritedModel.of(context).activatedWallet.wallet.getChainId(selectCoinType) ?? "";
    var webviewOptions = InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(useShouldInterceptRequest: true),
        dappOptions: DappOptions(walletAddress, rpcUrl, chainId,AppTabBarPage.initStr,AppTabBarPage.libraryStr));
    if (webView != null) {
      await webView.setOptions(options: webviewOptions);
    }
  }

  Future<bool> showSendDialogDApp<T>(
      {BuildContext context,
      String to,
      BigInt value,
      String valueUnit,
      int gasValue,
      String gasUnit,
      BigInt gasPrice,
      int coinType = CoinType.HB_HT,
      DAppSendEntityCallBack confirmAction}) async {
    if (to?.isEmpty ?? true) {
      Fluttertoast.showToast(msg: trans.S.of(context).net_error_please_again);
      return false;
    }

    var walletVo = WalletInheritedModel.of(context).activatedWallet;
    var wallet = walletVo.wallet;

    var walletName = wallet.keystore.name;

    var from = wallet.getAtlasAccount().address;
    // var fromAddressHyn = WalletUtil.ethAddressToBech32Address(from);
    var fromAddress = shortBlockChainAddress(from);

    // var toAddress = to;
    // if (_coinType == CoinType.HYN_ATLAS) {
    //   toAddress = WalletUtil.bech32ToEthAddress(to);
    // } else {
    //   toAddress = to;
    // }

    DAppSendDialogEntity entity = DAppSendDialogEntity(
      type: 'dApp_send_normal',
      value: value,
      valueUnit: valueUnit,
      title: S.of(context).contract_transfer,
      fromName: walletName,
      fromAddress: fromAddress,
      toName: shortBlockChainAddress(to),
      toAddress: '',
      gas: gasValue,
      gasDesc: '',
      gasUnit: gasUnit,
      gasPrice: gasPrice,
      isEnableEditGas: true,
      coinType: coinType,
      cancelAction: (String cancelStr, BigInt gasPrice) async {
        return false;
      },
      confirmAction: confirmAction,
    );

    return showDAppSendDialog(
      context: context,
      entity: entity,
      isDismissible: false,
    );
  }
}
