import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:xconn_ui/Providers/args_provider.dart";
import "package:xconn_ui/constants.dart";

class ArgsTextFormFields extends StatelessWidget {
  const ArgsTextFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ArgsProvider>(
      builder: (context, model, _) {
        return SizedBox(
          height: 120,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: model.controllers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: model.controllers[index],
                    decoration: InputDecoration(
                      labelText: "Enter args here",
                      labelStyle: TextStyle(color: blackColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: blackColor),
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
                  onTap: () => model.removeController(index),
                  child: Icon(
                    Icons.delete,
                    color: closeIconColor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
