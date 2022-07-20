import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuctionTableOutput extends StatelessWidget {
  final List<TableRow> rows;
  const AuctionTableOutput({Key? key, required this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey,
        width: 2,
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
      ), // Allows to add a border decoration around your table
      children: rows,
    );
  }
}
