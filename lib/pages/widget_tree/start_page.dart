import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prim_derma_app/bloc/auth/login/login_bloc.dart';
import 'package:prim_derma_app/pages/auth/login_page.dart';
import 'package:prim_derma_app/pages/widget_tree/home_page.dart';
import 'package:prim_derma_app/repo/env_variable.dart';

import 'package:prim_derma_app/widget/message_widget.dart';
import 'package:prim_derma_app/widget/style.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Widget page = startWidget();
  @override
  void initState() {
    super.initState();

    BlocProvider.of<LoginBloc>(context).add(AutoLogin());
  }

  void refreshNetwork() {
    page = startWidget();
    setState(() {});
    BlocProvider.of<LoginBloc>(context).add(AutoLogin());
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginWithoutNetwork) {
          await showPrimMessageDialog(context,'Tiada capaian', 
              "Pastikan anda mempunyai capaian internet.");
          page = pendingNetworkWidget(refreshNetwork);
        } else if (state is LoginSuccess) {
          HomePage.selectedTab = 0;
          page = const HomePage();
        } else if (state is LoginFailure) {
          page = const LoginPage();
          await showPrimMessageDialog(context,'Ralat', state.error);
        } else if (state is LoginFailureWithoutError) {
          page = const LoginPage();
        } else if (state is LoginInitial || state is LogoutSuccess) {
          refreshNetwork();
        }

        if (state is LoginLoading) {
          showLoadingWidget(context);
        } else {
          endLoadingWidget();
        }
        setState(() {});
      },
      child: page,
    );
  }
}

Widget startWidget() {
  return Scaffold(
      body: Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HIGHLIGHT_TEXT_COLOR),
          ),
        ]),
  ));
}

Widget pendingNetworkWidget(Function func) {
  return Scaffold(
    appBar: PrimAppBar('Ralat'),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Tiada Capaian Internet',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(height: 40),
          IconButton(
            onPressed: () {
              func();
            },
            icon: Icon(
              Icons.refresh,
              size: 50,
              color: HIGHLIGHT_TEXT_COLOR,
            ),
          )
        ],
      ),
    ),
  );
}
