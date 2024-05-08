import 'package:flutter/material.dart';
import 'package:jejal_project/models/file_result_model.dart';  // Import your model file here

class ResultScreenDetail extends StatelessWidget {
  final FileResultModel fileResult;

  ResultScreenDetail({Key? key, required this.fileResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Segments Detail'),
      ),
      body: fileResult.data != null && fileResult.data!.segments != null
          ? ListView.builder(
        itemCount: fileResult.data!.segments!.length,
        itemBuilder: (context, index) {
          var segment = fileResult.data!.segments![index];
          return ListTile(
            title: Text(segment.jeju ?? 'No Jeju Text'),
            subtitle: Text(segment.translated ?? 'No Translation'),
          );
        },
      )
          : Center(
        child: Text('No segments data available'),
      ),
    );
  }
}
