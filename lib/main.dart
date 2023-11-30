import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => const NestedTabBarView1(),
        "/jump": (context) => const NewRouter(),
        "/test": (context) => WillPopScopeTestRoute()
      },
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
    );
  }
}

class WillPopScopeTestRoute extends StatefulWidget {
  @override
  WillPopScopeTestRouteState createState() {
    return WillPopScopeTestRouteState();
  }
}

class WillPopScopeTestRouteState extends State<WillPopScopeTestRoute> {
  DateTime? _lastPressedAt; //上次点击时间
  var _canPop = false;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: NavigatorPopHandler(child: Text('allert'),onPop: (){print("pop");},enabled: false,),
      appBar: CupertinoNavigationBar(
        middle: Text("test"),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage>   {
  var focusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  var currentActiveNode = 0;
  var _formKey = GlobalKey();
  var mailReg = RegExp(
      "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z0-9]{2,6}\$");

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 18,
      ),
      child: Scaffold(
        appBar: CupertinoNavigationBar(
            middle: const Text("首页"),
            border: null,
            trailing: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/jump");
                },
                child: const Icon(Icons.search))),
        body: GestureDetector(
          onTap: () {
            for (var value in focusNodes) {
              value.unfocus();
            }
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: focusNodes[0],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        return v!.trim().isEmpty
                            ? "邮箱不可以为空"
                            : !mailReg.hasMatch(v)
                            ? "邮箱格式不正确"
                            : null;
                      },
                      decoration: const InputDecoration(
                        labelText: "邮箱",
                        hintText: "请输入邮箱",
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(
                            color: Color(0xFFCE001A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      focusNode: focusNodes[1],
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      cursorRadius: const Radius.circular(50),
                      validator: (v) {
                        return v!.isEmpty
                            ? "密码不可以为空"
                            : v.length < 6
                            ? "密码最少六位"
                            : null;
                      },
                      decoration: const InputDecoration(
                          labelText: "密码",
                          hintText: "请输入密码",
                          hintStyle: TextStyle(color: Color(0xFF535770)),
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(100)),
                            borderSide: BorderSide(
                              color: Color(0xFFCE001A),
                            ),
                          ),
                          focusColor: Colors.amber),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      return SizedBox(
                          width: double.infinity,
                          child: Builder(builder: (context) {
                            return CupertinoButton.filled(
                              onPressed: () async {
                                if (Form.of(context).validate()) {
                                  var url = Uri.http('www.baidu.com');
                                  var response = await http.get(url);
                                  print(
                                      'Response status: ${response
                                          .statusCode}');
                                  print('Response body: ${response.body}');
                                }
                              },
                              child: const Text("登陆"),
                              borderRadius: BorderRadius.circular(50),
                            );
                          }));
                    }),
                    const SizedBox(height: 40),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade50,
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      value: .2,
                    ),
                    Container(
                      width: 80,
                      color: Colors.black,
                      child: Container(
                        alignment: Alignment.topLeft,
                        transform: Matrix4.skewY(0.3),
                        padding: const EdgeInsets.all(8),
                        color: Colors.deepOrange,
                        child: const Text("测试文档"),
                      ),
                    ),
                    Container(
                      height: 100,
                      child: FittedBox(
                          fit: BoxFit.contain, child: Text('ssssss' * 20)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LayoutLogPrint<T> extends StatelessWidget {
  const LayoutLogPrint({
    Key? key,
    this.tag,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final T? tag; //指定日志tag

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      // assert在编译release版本时会被去除
      assert(() {
        print('${tag ?? key ?? child}: $constraints');
        return true;
      }());
      return child;
    });
  }
}

class ResponsiveColumn extends StatelessWidget {
  const ResponsiveColumn({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // 通过 LayoutBuilder 拿到父组件传递的约束，然后判断 maxWidth 是否小于200
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 200) {
          // 最大宽度小于200，显示单列
          return Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
          );
        } else {
          // 大于200，显示双列
          var _children = <Widget>[];
          for (var i = 0; i < children.length; i += 2) {
            if (i + 1 < children.length) {
              _children.add(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  children[i],
                  const SizedBox(
                    width: 12,
                  ),
                  children[i + 1]
                ],
              ));
              _children.add(const SizedBox(
                height: 12,
              ));
            } else {
              _children.add(children[i]);
            }
          }
          return Column(
            children: _children,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          );
        }
      },
    );
  }
}

class NewRouter extends StatelessWidget {
  const NewRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // AppBar，包含一个导航栏.
          SliverAppBar(
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: null,
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              title: const Text('Demo'),
              background: Container(
                color: Colors.orangeAccent,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              //Grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //Grid按两列显示
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 4.0,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  //创建子widget
                  return Container(
                    alignment: Alignment.center,
                    color: Colors.cyan[100 * (index % 9)],
                    child: Text('grid item $index'),
                  );
                },
                childCount: 20,
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                //创建列表项
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('list item $index'),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class NestedTabBarView1 extends StatelessWidget {
  const NestedTabBarView1({Key? key}) : super(key: key);

  Widget buildSliverList([int count = 5]) {
    return SliverFixedExtentList(
      itemExtent: 50,
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return ListTile(title: Text('$index'));
        },
        childCount: count,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _tabs = <String>['猜你喜欢', '今日特价', '发现更多'];
    // 构建 tabBar
    return DefaultTabController(
      length: _tabs.length, // tab的数量.
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/test');
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: const Color(0x3cd5d5d5)),
                                  color: const Color(0xdd5d5d5),
                                  borderRadius: BorderRadius.circular(30)),
                              margin: const EdgeInsets.only(right: 20),
                              child: const Padding(
                                padding: EdgeInsets.all(13.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 22,
                                      color: Colors.grey,
                                    ),
                                    Expanded(
                                        child: Center(
                                            child: Text(
                                              "点击搜索",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey),
                                            )))
                                  ],
                                ),
                              ),
                            ),
                          )),
                      const CircleAvatar(
                        radius: 23,
                      )
                    ],
                  ),
                  pinned: true,
                  floating: true,
                  snap: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) {
              return Builder(
                builder: (BuildContext context) {
                  return CustomScrollView(
                    key: PageStorageKey<String>(name),
                    slivers: <Widget>[
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: buildSliverList(50),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
