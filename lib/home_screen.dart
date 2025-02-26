import 'package:db_data/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbHelper;
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); // Add this line

  @override
  void initState() {
    dbHelper = DBHelper.getInstance;
    getAllNotes();
    super.initState();
  }

  void getAllNotes() async {
    allNotes = await dbHelper!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Add this line
      appBar: AppBar(
        title: Text(
          "To-DO",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          allNotes.isNotEmpty
              ? ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allNotes[index][DBHelper.COLUMN_NOTE_TITLE],
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC], style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                showDragHandle: true,
                                context: context,
                                builder: (context) {
                                  titleController.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                                  descController.text = allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                                  return _showModalBottomSheet(isUpdate: true, sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                                },
                              );
                            },
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.primary),
                          ),
                          IconButton.filledTonal(
                            onPressed: () async {
                              bool isCheck = await dbHelper!.deleteNotes(sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                              if (isCheck) {
                                getAllNotes();
                              }
                            },
                            visualDensity: VisualDensity.compact,
                            color: Theme.of(context).colorScheme.error,
                            icon: Icon(Icons.delete, size: 16, color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 16);
                },
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                    SizedBox(height: 12),
                    Text(
                      "No Data Found",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            showDragHandle: true,
            context: context,
            builder: (context) {
              return _showModalBottomSheet();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _showModalBottomSheet({bool isUpdate = false, int sno = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('${isUpdate ? 'Update' : 'Add'} Note Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: "Title",
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: descController,
            maxLines: 4,
            minLines: 4,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: "Description",
            ),
          ),
          SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () async {
              var title = titleController.text;
              var desc = descController.text;
              if (title.isNotEmpty && desc.isNotEmpty) {
                bool isCheck =
                    await (isUpdate
                        ? dbHelper!.updateNotes(mTitle: title, mDesc: desc, sno: sno)
                        : dbHelper!.addNote(mTitle: title, mDesc: desc));
                if (isCheck) {
                  getAllNotes();
                  titleController.clear();
                  descController.clear();
                  Navigator.pop(context);
                }
              } else {
                ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                  SnackBar(content: Text('Please enter all details.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                );
                Navigator.pop(context);
              }
            },
            child: Text("${isUpdate ? 'Update' : 'Add'} Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
