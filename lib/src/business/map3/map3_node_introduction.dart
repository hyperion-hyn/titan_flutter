import 'package:flutter/material.dart';

class Map3NodeIntroductionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Map3IntroductionState();
  }
}

class _Map3IntroductionState extends State<Map3NodeIntroductionPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0), child: Image.asset("res/drawable/map3_node_introduction.jpeg")));
  }
}

//class _Map3IntroductionState extends State<Map3NodeIntroductionPage> {
//  @override
//  Widget build(BuildContext context) {
//    return SingleChildScrollView(
//      child: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Column(
//          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(left: 0, right: 16, top: 8),
//                    child: Image.asset(
//                      "res/drawable/cloud_1.png",
//                      width: 32,
//                    ),
//                  ),
//                  Expanded(
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Text(
//                          "云节点",
//                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 3),
//                          child: Text(
//                            "通过PC端提供地图数据服务的Map3节点，目前已开通该节点功能",
//                            softWrap: true,
//                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
//                          ),
//                        )
//                      ],
//                    ),
//                  )
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(left: 0, right: 16, top: 8),
//                    child: Image.asset(
//                      "res/drawable/cloud_2.png",
//                      width: 32,
//                    ),
//                  ),
//                  Expanded(
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Text(
//                          "雾节点",
//                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 3.0),
//                          child: Text(
//                            "通过手机端提供地图数据服务的Titan节点，预计在2020年6月开通",
//                            softWrap: true,
//                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
//                          ),
//                        )
//                      ],
//                    ),
//                  )
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(left: 0, right: 16, top: 8),
//                    child: Image.asset(
//                      "res/drawable/cloud_3.png",
//                      width: 32,
//                    ),
//                  ),
//                  Expanded(
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Text(
//                          "共识节点",
//                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//                        ),
//                        Padding(
//                          padding: const EdgeInsets.only(top: 3.0),
//                          child: Text(
//                            "又称为Atlas链上节点或出块节点，预计在2020年9月主网上线时开通",
//                            softWrap: true,
//                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
//                          ),
//                        )
//                      ],
//                    ),
//                  )
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10),
//              child: Divider(
//                thickness: 1.3,
//              ),
//            ),
//            Text(
//              '''        成为云节点：竞选云节点的用户需在网络中抵押总量为100w的HYN。或选择抵押最低值20w，并从多个普通钱包用户中收集80w的HYN累计以达到100w的数值。商家调用地图服务时，将抵押量30%将用于服务节点奖励。云节点从服务收益中获取20%作为个人所得，剩余的80%返还给参与该节点的普通钱包用户。而一旦网络发现服务节点作恶，将没收其20%的收益，但不会影响普通用户。第一年海伯利安将为云节点提供额外补贴。从现在起至2020年9月，云节点最高的补贴后月化收益将达到3%，补贴结束后将回到1%。\n
//
//        成为雾节点：竞选雾节点的用户只需抵押总数为10w的HYN，或选择抵押最低值2w个HYN，并从多个普通钱包收集8w个HYN以累计达到10w的数值。雾节点的服务奖励比与云节点相同。待雾节点开通时，补贴后的月化收益预计在2%。所有补贴将在主网上线前发放完毕。之后，服务节点的月化收益将回到1%。
//
//        成为链上节点：竞选链上节点的用户必须已经成为服务节点，并在服务节点的抵押基础上累计抵押总量为1000w个HYN。或选择抵押最低值200w个HYN，并从其他服务节点收集剩余800w个HYN以累计达到1000w的数值。链上节点收益更大，包含服务奖励和区块奖励。预计平均月化收益为2.5%-4%，年化为35%左右。''',
//              softWrap: true,
//              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//}
