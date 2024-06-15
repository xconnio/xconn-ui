import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wick_ui/providers/kwargs_provider.dart";

class DynamicKeyValuePairs extends StatefulWidget {
  const DynamicKeyValuePairs({required this.provider, super.key});

  final KwargsProvider provider;

  @override
  State<DynamicKeyValuePairs> createState() => _DynamicKeyValuePairsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<KwargsProvider>("provider", provider));
  }
}

class _DynamicKeyValuePairsState extends State<DynamicKeyValuePairs> {
  @override
  Widget build(BuildContext context) {
    return Consumer<KwargsProvider>(
      builder: (context, tableProvider, _) {
        Map<String, String> kWarValues = {};
        for (final mapEntry in tableProvider.tableData) {
          if (mapEntry.key.isNotEmpty) {
            kWarValues[mapEntry.key] = mapEntry.value;
          }
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
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
                      onPressed: () {
                        setState(() {
                          widget.provider.addRow(const MapEntry("", ""));
                        });
                      },
                      icon: const Icon(
                        Icons.add_box_sharp,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              TableWidget(widget.provider.tableData, widget.provider),
            ],
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<KwargsProvider>("provider", widget.provider));
  }
}

class TableWidget extends StatefulWidget {
  const TableWidget(this.tableData, this.kwargsProvider, {super.key});

  final List<MapEntry<String, String>> tableData;
  final KwargsProvider kwargsProvider;

  @override
  State<TableWidget> createState() => _TableWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<MapEntry<String, String>>("tableData", tableData))
      ..add(DiagnosticsProperty<KwargsProvider>("kwargsProvider", kwargsProvider));
  }
}

class _TableWidgetState extends State<TableWidget> {
  TableRow _buildTableRow(MapEntry<String, String> rowData, int index) {
    return TableRow(
      children: [
        _buildTableCell(
          TextFormField(
            initialValue: rowData.key,
            onChanged: (newValue) {
              final updatedEntry = MapEntry<String, String>(newValue, rowData.value);
              widget.kwargsProvider.updateRow(index, updatedEntry);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
        _buildTableCell(
          TextFormField(
            initialValue: rowData.value,
            onChanged: (newValue) {
              final updatedEntry = MapEntry<String, String>(rowData.key, newValue);
              widget.kwargsProvider.updateRow(index, updatedEntry);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
        _buildTableCell(
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                widget.kwargsProvider.removeRow(index);
              });
            },
          ),
        ),
      ],
    );
  }

  TableCell _buildTableCell(Widget child) {
    return TableCell(
      child: Container(
        alignment: Alignment.center,
        height: 50,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.tableData.isNotEmpty
        ? Table(
            border: TableBorder.all(color: Colors.grey),
            columnWidths: const {
              0: FixedColumnWidth(150),
              1: FixedColumnWidth(150),
              2: FixedColumnWidth(50),
            },
            children: [
              TableRow(
                children: [
                  _buildTableCell(
                    const Text(
                      "Key",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildTableCell(
                    const Text(
                      "Value",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildTableCell(
                    const Text(
                      "",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...widget.tableData.asMap().entries.map((entry) => _buildTableRow(entry.value, entry.key)),
            ],
          )
        : Container();
  }
}
