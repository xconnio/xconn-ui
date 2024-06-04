import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:wick_ui/constants.dart";
import "package:wick_ui/providers/args_provider.dart";

class ArgsTextFormFields extends StatefulWidget {
  const ArgsTextFormFields({required this.provider, super.key});

  final ArgsProvider provider;

  @override
  State<ArgsTextFormFields> createState() => _ArgsTextFormFieldsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ArgsProvider>("provider", provider));
  }
}

class _ArgsTextFormFieldsState extends State<ArgsTextFormFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
                    "Args",
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
                    widget.provider.addController();
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
        SizedBox(
          height: 120,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.provider.controllers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: widget.provider.controllers[index],
                    decoration: InputDecoration(
                      labelText: "Enter args here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                trailing: InkWell(
                  hoverColor: Colors.blue.shade200,
                  onTap: () {
                    setState(() {
                      widget.provider.removeController(index);
                    });
                  },
                  child: Icon(
                    Icons.delete,
                    color: closeIconColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ArgsProvider>("provider", widget.provider));
  }
}
