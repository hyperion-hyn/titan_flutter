class TranstionDetailVo {
  int type; //1、转出 2、转入
  int state;
  double amount;
  String unit;
  String fromAddress;
  String toAddress;
  int time;
  String hash;

  TranstionDetailVo(
      {this.type, this.state, this.amount, this.unit, this.fromAddress, this.toAddress, this.time, this.hash});
}
