// import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_up/api/apis.dart';
import 'package:chat_up/models/chat_user.dart';
import 'package:chat_up/screens/auth/profile_screen.dart';
import 'package:chat_up/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    await APIs.getSelfInfo(); 
    setState(() {}); // Update UI after fetching self info
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        onPopInvoked: (result) async{
          if (_isSearching){
            setState(() {
              _isSearching =! _isSearching;
            });
            return Future.value(true);

          }
          else {
            return Future.value(false) ;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search by Name or Email...',
                    ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      setState(() {
                        _searchList = _list
                            .where((user) =>
                                user.name.toLowerCase().contains(val.toLowerCase()) ||
                                user.email.toLowerCase().contains(val.toLowerCase()))
                            .toList();
                      });
                    },
                  )
                : const Text('ChatUp'),
            backgroundColor: const Color.fromRGBO(141, 188, 236, 1),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching ? CupertinoIcons.clear_circled_solid : Icons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)),
                  );
                },
                icon: const Icon(Icons.person),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Icon(Icons.add_comment_rounded),
            backgroundColor: const Color.fromRGBO(141, 188, 236, 1),
          ),
          body: FutureBuilder(
            future: APIs.getSelfInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return StreamBuilder(
                  stream: APIs.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final data = snapshot.data?.docs;
                      _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        
                      return ListView.builder(
                        itemCount: _isSearching ? _searchList.length : _list.length,
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = _isSearching ? _searchList[index] : _list[index];
                          return ChatUserCard(user: user);
                        },
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
