import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prim_derma_app/bloc/auth/login/login_bloc.dart';
import 'package:prim_derma_app/bloc/derma/derma_bloc.dart';
import 'package:prim_derma_app/models/derma.dart';
import 'package:prim_derma_app/models/user.dart';
import 'package:prim_derma_app/pages/derma/derma_function.dart';
import 'package:prim_derma_app/pages/derma/derma_webpage.dart';

import 'package:prim_derma_app/widget/style.dart';

class DermaPage extends StatefulWidget {
  const DermaPage({super.key});

  @override
  State<DermaPage> createState() => _DermaPageState();
}

class _DermaPageState extends State<DermaPage> {
  static List<String> headerList = [];
  static List<Derma> dermaList = [];
  static List<Derma> dermaHistoryList = [];
  List<Derma> tempDermaList = [];

  String _selectedType = '';
  late ScrollController _scrollController;

  // Custom setter for selectedType
  set selectedType(String value) {
    _selectedType = value;

    if (_selectedType == 'Sejarah Derma Anda') {
      tempDermaList = dermaHistoryList;
    } else {
      tempDermaList =
          dermaList.where((x) => x.donationType == selectedType).toList();
    }
  }

  String get selectedType => _selectedType;

  void retrieveDermaHistory() async {
    var list = await Derma.getDermaHistory();
    dermaHistoryList = list;
    setState(() {});
  }

  void _animateScroll() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, // Scroll to the end
      duration: const Duration(seconds: 5), // Duration of the animation
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    retrieveDermaHistory();
    BlocProvider.of<DermaBloc>(context).add(RequestDermaList());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DermaBloc, DermaState>(
      listener: (context, state) {
        if (state is DermaFetched) {
          dermaList = state.dermaList;
          headerList = state.dermaTypeList;
          headerList.sort((a, b) {
            return Random().nextInt(20) - Random().nextInt(20);
          });

          dermaList.sort((a, b) {
            return Random().nextInt(20) - Random().nextInt(20);
          });
          //headerList = [];
          if (dermaHistoryList.isNotEmpty) {
            headerList.insert(0, 'Sejarah Derma Anda');
          }
          selectedType = headerList.isNotEmpty ? headerList[0] : '';

          setState(() {});
        } else if (state is UpdateDermaType) {
          selectedType = state.type;

          setState(() {});
        }
      },
      child: body(),
    );
  }

  Widget animatedTypeCard(String type) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: 0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(50 * value, 0),
            child: child,
          ),
        );
      },
      child: typeCard(type),
    );
  }

  Widget typeCard(String type) {
    return GestureDetector(
      onTap: () {
        // Handle option selection
        selectedType = type;
        setState(() {});
      },
      child: Card(
        shadowColor: Colors.black,
        elevation: 3,
        color: type == selectedType ? PRIMARY_PURPLE : Colors.white,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(type,
                style: TextStyle(
                    color: type == selectedType
                        ? Colors.white
                        : HIGHLIGHT_TEXT_COLOR,
                    fontWeight: type == selectedType
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget dermaCard(Derma derma) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey[700],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: PrimPrimaryGradient()),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                derma.dermaName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 16, color: Colors.grey[900], letterSpacing: 1.1
                    // fontFamily: fon, // Custom font
                    ),
              ),
              SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      primaryColor:
                          Colors.white, // Change this to your desired color
                    ),
                    child: CupertinoButton.filled(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: Text(
                          'Derma',
                          style: TextStyle(
                              color: HIGHLIGHT_TEXT_COLOR,
                              fontWeight: FontWeight.w500),
                        ),
                        onPressed: () async {
                          var result = await showDermaActionSheet(context,
                              ['Derma Dengan Nama', 'Derma Tanpa Nama']);
                          if (result == null) {
                            return;
                          }

                          if (await User.validateLogin()) {
                            var token = await User.retrieveToken();
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DonateWebView(
                                      donation_id: derma.id.toString(),
                                      desc: result,
                                      token: token!,
                                      derma: derma,
                                    )));
                            retrieveDermaHistory();
                          } else {
                            BlocProvider.of<LoginBloc>(context)
                                .add(AutoLogin());
                          }
                        }),
                  )),
            ],
        
          ),
        ),
      ),
    );
  }

  Widget body() {
    return Scaffold(
      appBar: PrimAppBar(
        'Jom Derma',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double containerHeight = min(constraints.maxHeight * 0.23, 250);
          double cardFontSize = constraints.maxWidth < 600 ? 24 : 28;

          containerHeight = containerHeight +
              ((constraints.maxHeight < constraints.maxWidth)
                  ? (constraints.maxHeight * 0.24)
                  : 0);

          return Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, left: 5),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  border: Border(
                    bottom: BorderSide(color: PRIMARY_PURPLE, width: 6),
                    left: BorderSide(color: PRIMARY_PURPLE, width: 1.5),
                    top: BorderSide(color: PRIMARY_PURPLE, width: 1.5),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                height: containerHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if (constraints.maxHeight > constraints.maxWidth)
                      Text(
                        'Jenis Derma',
                        style: TextStyle(
                          fontSize: cardFontSize,
                          fontWeight: FontWeight.bold,
                          color: HIGHLIGHT_TEXT_COLOR,
                        ),
                      ),
                    SizedBox(
                      height: min(containerHeight * 0.55, 120),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: headerList.length,
                        itemBuilder: (context, index) {
                          return animatedTypeCard(headerList[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Expanded(
                child: ListView.builder(
                  itemCount: tempDermaList.length,
                  itemBuilder: (context, index) {
                    return dermaCard(tempDermaList[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
