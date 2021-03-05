import 'package:flutter/material.dart';
import 'package:titan/generated/l10n.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:titan/src/basic/widget/base_app_bar.dart';
import 'package:titan/src/components/app_lock/util/app_lock_util.dart';
import 'package:titan/src/components/wallet/wallet_component.dart';
import 'package:titan/src/plugins/wallet/cointype.dart';
import 'package:titan/src/plugins/wallet/wallet_util.dart';
import 'package:titan/src/style/titan_sytle.dart';
import 'package:titan/src/utils/utile_ui.dart';
import 'package:titan/src/widget/widget_shot.dart';

class DAppWebViewPage extends StatefulWidget {

  final String initUrl;
  final String title;
  final bool isShowAppBar;

  DAppWebViewPage({
    this.initUrl,
    this.title = '',
    this.isShowAppBar = true,
  });

  @override
  State<StatefulWidget> createState() {
    return DAppWebViewPageState();
  }
}

class DAppWebViewPageState extends State<DAppWebViewPage> {
  final ShotController _shotController = new ShotController();

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
  var selectCoinType = CoinType.HYN_ATLAS;

  @override
  void didChangeDependencies() {
    updateNetwork();

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
            /*IconButton(
              icon: Icon(Icons.share),
              tooltip: S.of(context).share,
              onPressed: () {
                _shareQr(context);
              },
            ),*/
            InkWell(
                onTap: (){
                  _showNetworkSelect();
                },
                child: Center(child: Text("${getCoinTypeStr()}网络",style: TextStyles.textC333S14,))),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _shareQr(context);
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
                SizedBox(height: 2, child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
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

    return InAppWebView(

      initialUrl: widget.initUrl,
      initialHeaders: {},
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(useShouldInterceptRequest: true),
          dappOptions: DappOptions(walletAddress,rpcUrl,chainId)
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;

        initDappJsHandle(controller);
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        //print("onLoadStart $url");
        setState(() {
          this.url = url;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        isLoading = false;
        print("onLoadStop $url");
        setState(() {
          this.url = url;
        });

        updateBackOrForward();
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        //print("onProgressChanged $url");

        setState(() {
          this.progress = progress / 100;
          //print('[inapp] --> webView, progress:${progress}');
        });
      },
      onConsoleMessage: (_,message){
        print("!!!!!onConsoleMessage $message");
      },
    );
  }

  void _showNetworkSelect(){
    UiUtil.showBottomDialogView(
      context,
      dialogHeight: MediaQuery.of(context).size.height - 80,
      isScrollControlled: true,
      customWidget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text("选择网络", style: TextStyles.textC333S14bold),
            ),
          ),
          networkItem("res/drawable/ic_token_hyn.png","Atlas",CoinType.HYN_ATLAS),
          networkItem('res/drawable/ic_token_eth.png',"Ethereum",CoinType.ETHEREUM),
          networkItem("res/drawable/ic_token_ht.png","Heco",CoinType.HB_HT),
        ],
      ),
    );
  }

  Widget networkItem(String imagePath,String networkName,int coinType){
    return InkWell(
      onTap: () async {
        selectCoinType = coinType;
        await updateNetwork();
        setState(() {

        });
        Future.delayed(Duration(milliseconds: 1000),(){
          webView.reload();
        });
        Navigator.of(context).pop();
      },
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16,right: 10,top: 15,bottom: 15),
                child: Image.asset(imagePath,width: 40,height: 40,),
              ),
              Text(networkName,style: TextStyles.textC333S16bold,)
            ],
          ),
          Divider(height:1,indent: 16,endIndent: 16,)
        ],
      ),
    );
  }

  void initDappJsHandle(InAppWebViewController controller){
    controller.addJavaScriptHandler(handlerName: "signTransaction", callback: (data){
      print("!!!!signTransaction $data");
    });

    controller.addJavaScriptHandler(handlerName: "signMessage", callback: (data){
      print("!!!!signMessage $data");
      flutterCallToWeb(controller, "executeCallback(${data[0]}, null, \"hello callback native\")");
    });

    controller.addJavaScriptHandler(handlerName: "signPersonalMessage", callback: (data){
      print("!!!!signPersonalMessage $data");
    });

    controller.addJavaScriptHandler(handlerName: "signTypedMessage", callback: (data){
      print("!!!!signTypedMessage $data");
    });

    controller.addJavaScriptHandler(handlerName: "ethCall", callback: (data){
      print("!!!!ethCall $data");
    });
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

  void _shareQr(BuildContext context) async {
    if (webView != null && !isLoading) {
      webView.takeScreenshot().then((imageByte) async {
        var len = imageByte.lengthInBytes;
        //debugPrint("screenshot taken bytes $len");

        AppLockUtil.ignoreAppLock(context, true);

        await Share.file(S.of(context).nav_share_app, 'app.png', imageByte, 'image/png');
      });
    }
  }

  String getCoinTypeStr(){
    switch(selectCoinType){
      case CoinType.HYN_ATLAS:
        return "Atlas";
      case CoinType.ETHEREUM:
        return "Ethereum";
      case CoinType.HB_HT:
        return "Heco";
    }
    return "";
  }

  updateNetwork() async {
    walletAddress = WalletInheritedModel.of(context).activatedWallet.wallet.getEthAccount().address ?? "";
    rpcUrl = WalletUtil.getRpcApiByCoinType(selectCoinType) ?? "";
    chainId = WalletInheritedModel.of(context).activatedWallet.wallet.getChainId(selectCoinType) ?? "";
    var webviewOptions = InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(useShouldInterceptRequest: true),
        dappOptions: DappOptions(walletAddress,rpcUrl,chainId)
    );
    if(webView != null){
      await webView.setOptions(options: webviewOptions);
    }
  }
}