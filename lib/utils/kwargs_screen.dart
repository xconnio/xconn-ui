import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:xconn_ui/Providers/kwargs_provider.dart";
import "package:xconn_ui/constants/my_constant.dart";

class DynamicKeyValuePairs extends StatelessWidget {
  const DynamicKeyValuePairs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TableDataProvider>(
      builder: (context, tableProvider, _) {
        return SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: TableWidget(tableProvider.tableData),
          ),
        );
      },
    );
  }
}

class TableWidget extends StatefulWidget {
  const TableWidget(this.tableData, {super.key});
  final List<Map<String, String>> tableData;

  @override
  State<TableWidget> createState() => _TableWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Map<String, String>>("tableData", tableData));
  }
}

class _TableWidgetState extends State<TableWidget> {
  TableRow _buildTableRow(
    Map<String, String> rowData,
    int index,
    TableDataProvider tableProvider,
  ) {
    return TableRow(
      children: [
        _buildTableCell(
          TextFormField(
            initialValue: rowData["key"],
            onChanged: (newValue) {
              // setState(() {
              //   rowData["key"] = newValue;
              // });
              rowData["key"] = newValue;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
        _buildTableCell(
          TextFormField(
            initialValue: rowData["value"],
            onChanged: (newValue) {
              rowData["value"] = newValue;
              // setState(() {
              //   rowData["value"] = newValue;
              // });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ),
        _buildTableCell(
          IconButton(
            icon: Icon(
              Icons.delete,
              color: closeIconColor,
            ),
            onPressed: () {
              tableProvider.removeRow(index);
              // setState(() {});
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
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FixedColumnWidth(150),
        1: FixedColumnWidth(150),
        2: FixedColumnWidth(50),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
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
        ...widget.tableData.asMap().entries.map(
              (entry) => _buildTableRow(
                entry.value,
                entry.key,
                Provider.of<TableDataProvider>(context),
              ),
            ),
      ],
    );
  }
}
