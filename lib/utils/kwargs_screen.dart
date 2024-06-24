import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";

class DynamicKeyValuePairs extends StatefulWidget {
  const DynamicKeyValuePairs({required this.kwargsProvider, super.key});

  final KwargsProvider kwargsProvider;

  @override
  State<DynamicKeyValuePairs> createState() => _DynamicKeyValuePairsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<KwargsProvider>("kwargsProvider", kwargsProvider));
  }
}

class _DynamicKeyValuePairsState extends State<DynamicKeyValuePairs> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Kwargs",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _showAddDialog(context);
                },
                icon: const Icon(
                  Icons.add_box_sharp,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Consumer<KwargsProvider>(
            builder: (context, provider, child) {
              return provider.tableData.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: DataTable(
                        columnSpacing: 50,
                        border: TableBorder.all(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                        columns: const [
                          DataColumn(
                            label: Text("Key"),
                            tooltip: "Key",
                          ),
                          DataColumn(
                            label: Text("Value"),
                            tooltip: "Value",
                          ),
                          DataColumn(
                            label: Text("Actions"),
                            tooltip: "Actions",
                          ),
                        ],
                        rows: provider.tableData
                            .asMap()
                            .entries
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(entry.value.key),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: Text(entry.value.value),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        provider.removeRow(entry.key);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    String key = "";
    String value = "";

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add kwargs"),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Key",
                  ),
                  onChanged: (newValue) {
                    key = newValue; // Update key variable
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Value",
                  ),
                  onChanged: (newValue) {
                    value = newValue; // Update value variable
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                widget.kwargsProvider.addRow(key, value);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
