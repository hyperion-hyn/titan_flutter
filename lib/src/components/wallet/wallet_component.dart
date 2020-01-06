import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:titan/src/components/wallet/vo/wallet_vo.dart';

import 'bloc/bloc.dart';
import 'wallet_repository.dart';

class WalletComponent extends StatelessWidget {
  final Widget child;

  WalletComponent({@required this.child});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (ctx) => WalletRepository(),
      child: BlocProvider<WalletCmpBloc>(
        create: (ctx) => WalletCmpBloc(walletRepository: RepositoryProvider.of<WalletRepository>(ctx)),
        child: _WalletManager(child: child),
      ),
    );
  }
}

class _WalletManager extends StatefulWidget {
  final Widget child;

  _WalletManager({@required this.child});

  @override
  State<StatefulWidget> createState() {
    return _WalletManagerState();
  }
}

class _WalletManagerState extends State<_WalletManager> {
  WalletVo _activatedWallet;

  @override
  void initState() {
    super.initState();

    //load default wallet
    BlocProvider.of<WalletCmpBloc>(context).add(FindBestWalletAndActiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCmpBloc, WalletCmpState>(
      builder: (BuildContext context, WalletCmpState state) {
        if (state is ActivatedWalletState) {
          _activatedWallet = state.walletVo;
        }
        return WalletViewModel(
          activatedWallet: _activatedWallet,
          child: widget.child,
        );
      },
    );
  }
}

enum WalletAspect {
  activatedWallet,
}

class WalletViewModel extends InheritedModel<WalletAspect> {
  final WalletVo activatedWallet;

  WalletViewModel({
    this.activatedWallet,
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  static WalletViewModel of(BuildContext context, {WalletAspect aspect}) {
    return InheritedModel.inheritFrom<WalletViewModel>(context, aspect: aspect);
  }

  @override
  bool updateShouldNotify(WalletViewModel oldWidget) {
    return activatedWallet != oldWidget.activatedWallet;
  }

  @override
  bool updateShouldNotifyDependent(WalletViewModel oldWidget, Set<WalletAspect> dependencies) {
    return (activatedWallet != oldWidget.activatedWallet && dependencies.contains(WalletAspect.activatedWallet));
  }

  static String formatPrice(double price) {
    return NumberFormat("#,###.#####").format(price);
  }
}
