import '/screens/viewUser.dart';
import '/screens/EditUser.dart';
import '/screens/addUser.dart';
import 'services/userService.dart';
import 'package:flutter/material.dart';
import '/model/User.dart'; // Replace with the correct package name


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<User> _userList = <User>[];
  late List<User> _filteredUserList = <User>[]; // New list for filtered users
  final _userService = UserService();

  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  getAllUserDetails() async {
    var users = await _userService.readAllUsers();
    _userList = <User>[];
    users.forEach((user) {
      setState(() {
        var userModel = User();
        userModel.id = user['id'];
        userModel.name = user['name'];
        userModel.contact = user['contact'];
        userModel.description = user['description'];
        _userList.add(userModel);
      });
    });
    // Initial set of filtered users
    _filteredUserList = List.from(_userList);
  }

  @override
  void initState() {
    getAllUserDetails();
    super.initState();
  }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _deleteFormDialog(BuildContext context, userId) {
    return showDialog(
      context: context,
      builder: (param) {
        return AlertDialog(
          title: const Text(
            'Are You Sure to Delete',
            style: TextStyle(color: Colors.teal, fontSize: 20),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                var result = await _userService.deleteUser(userId);
                if (result != null) {
                  Navigator.pop(context);
                  getAllUserDetails();
                  _showSuccessSnackBar('Contact Detail Deleted Success');
                }
              },
              child: const Text('Delete'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.black,fontSize: 16),
          onChanged: (value) {
            setState(() {
              _filteredUserList = _userList
                  .where((user) =>
              user.name!.toLowerCase().contains(value.toLowerCase()) ||
                  user.contact!.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
        )
            : const Text(
          "Contact",
          style: TextStyle(
            fontSize: 32,
          ),
        ),
        actions: [
          _isSearching
              ? IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _filteredUserList = List.from(_userList);
              });
            },
          )
              : IconButton(
            icon: Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Icon(Icons.search,size: 35,),
            ),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredUserList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewUser(
                          user: _filteredUserList[index],
                        )));
              },
              leading: const Icon(Icons.person),
              title: Text(_filteredUserList[index].name ?? ''),
              subtitle: Text(_filteredUserList[index].contact ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditUser(
                                user: _filteredUserList[index],
                              ))).then((data) {
                        if (data != null) {
                          getAllUserDetails();
                          _showSuccessSnackBar('Contact Detail Updated Success');
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.teal,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteFormDialog(
                          context, _filteredUserList[index].id);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddUser()))
              .then((data) {
            if (data != null) {
              getAllUserDetails();
              _showSuccessSnackBar('Contact Detail Added Success');
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

