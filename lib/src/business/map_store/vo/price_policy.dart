class PricePolicy {
  String id;
  String policyName;
  String policyUnit;
  double policyPrice;
  String policyDuration;
  String policyOldPrice;
  bool selected;

  PricePolicy(
      {this.id,
      this.policyName,
      this.policyUnit,
      this.policyPrice,
      this.policyDuration,
      this.policyOldPrice,
      this.selected});
}
