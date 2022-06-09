import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hiis_app/chaptermodel.dart';

import 'package:hiis_app/partmodel.dart';
import 'package:hiis_app/sectionmodel.dart';
import 'package:hiis_app/yeardata.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class HomePagenew extends StatefulWidget {
  const HomePagenew({Key? key}) : super(key: key);

  @override
  State<HomePagenew> createState() => _HomePagenewState();
}

class _HomePagenewState extends State<HomePagenew> {
  List<PartData>? partResponse;
  List<SectionData>? sectionResponse;
  List<ChapterData>? chapterResponse;
  List<ChapterData>? chapterResponse1;
  String? partvalue;
  String? sectionvalue;
  String? chaptervalue;
  TextEditingController _txtsearch = TextEditingController();

  Future<List<PartData>?> fetchData() async {
    try {
      http.Response response =
          await http.get(Uri.parse('http://103.87.24.58/hiisapi/PartMas'));
      if (response.statusCode == 200) {
        partResponse = partDataFromJson(response.body);
        return partResponse;
      } else {
        return throw Exception('Failed to load ...');
      }
    } catch (e) {
      return throw Exception('Failed to load ...');
    }
  }

  Future<List<SectionData>?> fetchsectData(String id) async {
    try {
      http.Response response = await http
          .get(Uri.parse('http://103.87.24.58/hiisapi/SectionMas/' + id));
      if (response.statusCode == 200) {
        sectionResponse = sectionDataFromJson(response.body);
        return sectionResponse;
      } else {
        return throw Exception('Failed to load ...');
      }
    } catch (e) {
      return throw Exception('Failed to load ...');
    }
  }

  Future<List<ChapterData>?> fetchchepttData() async {
    try {
      http.Response response =
          await http.get(Uri.parse('http://103.87.24.58/hiisapi/Chapter'));
      if (response.statusCode == 200) {
        chapterResponse = chapterDataFromJson(response.body);
        //  chapterResponse1 = chapterResponse;
        return chapterResponse;
      } else {
        return throw Exception('Failed to load ...');
      }
    } catch (e) {
      return throw Exception('Failed to load ...');
    }
  }

  Future<void> setSection(String id) async {
    sectionvalue = null;
    var d = await fetchsectData(id);
    setState(() {});
  }

  void filter() {
    if (_txtsearch.text.trim().isNotEmpty) {
      setState(() {
        chapterResponse1 = chapterResponse
            ?.where((element) => element.chapterName.contains(_txtsearch.text))
            .toList();
      });
    } else {
      setState(() {
        chapterResponse1 = chapterResponse1
            ?.where((element) => element.sectionCode == sectionvalue)
            .toList();
      });
    }
  }

  Future<void> setchapter(String id) async {
    chaptervalue = null;
    // var d = await fetchchepttData(id);
    var d = await fetchchepttData().then((value) => chapterResponse1 =
        value?.where((element) => element.sectionCode == id).toList());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    fetchData().then((users) {
      setState(() {
        partResponse = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(children: [
          Container(
            child: FormField<String>(builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                child: DropdownButton(
                  elevation: 16,
                  style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                  isExpanded: true,
                  hint: const Text(
                    "Part",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  value: partvalue,
                  // ignore: prefer_null_aware_operators
                  items: partResponse != null
                      ? partResponse?.map((item) {
                          return DropdownMenuItem<String>(
                              value: item.partCode.toString(),
                              child: Text(item.partName));
                        }).toList()
                      : null,
                  onChanged: (item) {
                    partvalue = item.toString();
                    setSection(partvalue.toString());
                  },
                ),
              );
            }),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            child: FormField<String>(builder: (FormFieldState<String> state) {
              return InputDecorator(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                child: DropdownButton(
                  elevation: 16,
                  style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  // underline: Container(
                  //   height: 2,
                  //   color: Colors.green,
                  // ),
                  isExpanded: true,
                  hint: const Text(
                    "Section",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  value: sectionvalue,
                  // ignore: prefer_null_aware_operators
                  items: sectionResponse != null
                      ? sectionResponse?.map((item) {
                          return DropdownMenuItem<String>(
                              value: item.sectionCode.toString(),
                              child: Text(item.sectionName));
                        }).toList()
                      : null,
                  onChanged: (item) {
                    sectionvalue = item.toString();
                    setchapter(sectionvalue.toString());
                  },
                ),
              );
            }),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Card(
              shape: const RoundedRectangleBorder(
                  side: BorderSide(width: 2, color: Colors.green)),
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                    controller: _txtsearch,
                    decoration: const InputDecoration(
                      hintText: 'Topic Search', border: InputBorder.none,
                      // hintText: 'search here...',
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.vertical())
                    ),
                    onChanged: (text) => filter()),
                trailing: const Icon(Icons.cancel),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 300,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    chapterResponse1 == null ? 0 : chapterResponse1?.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => yeardatacls(
                              // seccode: _txtsearch.toString()
                              // ignore: unrelated_type_equality_checks
                              seccode: chapterResponse1![index].sectionCode == 0
                                  ? chapterResponse1![index].sectionCode
                                  : chapterResponse1![index].sectionCode)));
                    },
                    child: Card(
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          textColor: Colors.green,
                          title: Text(
                            "${chapterResponse1![index].chapterName}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ]),
      ),
    ));
  }
}


//http://103.87.24.58/dsofiles/1994-95/f