import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:startup_namer/page/home_page.dart';
import '../database/locationDB.dart';
import '../service/locationDB_CRUD.dart' as tracking_system_db;
import './map_page.dart';

const kHighScoreTableHeaders = TextStyle(
  color: Colors.black,
  fontSize: 30.0,
  fontWeight: FontWeight.w300,
  letterSpacing: 1.0,
);

const kHighScoreTableRowsStyle = TextStyle(
  color: Colors.black,
  fontSize: 15.0,
  fontWeight: FontWeight.w300,
  letterSpacing: 1.0,
);

class RecordPage extends StatelessWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecordList();
  }
}

class RecordList extends StatefulWidget {
  const RecordList({Key? key}) : super(key: key);

  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  List<UserLocation> query = [];

  @override
  void initState() {
    super.initState();
    queryScores();
  }

  void queryScores() async {
    final database = tracking_system_db.openDB();
    var queryResult = await tracking_system_db.getList(database);
    setState(() {
      query = queryResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                        '${query[index].id}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20.0),
                      ),
                      subtitle: Text('${query[index].locDateTime}'),
                      leading: Icon(Icons.map, color: Colors.blue),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      });
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: query.length))
      ],
    ));
  }
}
