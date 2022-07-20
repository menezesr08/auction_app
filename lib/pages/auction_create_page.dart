import 'package:auction_app/services/auction_service.dart';
import 'package:auction_app/widgets/auction_table_output.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../utils/helper.dart';
import '../widgets/row_cell.dart';

class AuctionCreatePage extends StatefulWidget {
  AuctionService? auctionService;
  final String createAuctionTransactionRef;
  late Logger logger;
  String contractAddress = '';
  AuctionCreatePage({
    Key? key,
    required this.createAuctionTransactionRef,
  }) : super(key: key);

  @override
  State<AuctionCreatePage> createState() => _AuctionCreatePageState();
}

class _AuctionCreatePageState extends State<AuctionCreatePage> {
  final tableRows = [
    const TableRow(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        children: [
          Text(
            'Address',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            'Bid',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ]),

    TableRow(children: [
      RowCell(
        text: '2011',
      ),
      RowCell(
        text: 'Dart',
      ),
    ]),
    const TableRow(children: [
      Text('1996'),
      Text('Java'),
    ]),
  ];
  @override
  void initState() {
    widget.logger = Logger();
    widget.logger.d(
        'Current auction service - deployed contract: ${widget.auctionService?.auctionCreatorContract.address}');
    deployContract();
    super.initState();
  }

  void deployContract() async {
    widget.auctionService = context.read<AuctionService>();
    List<dynamic> res = await widget.auctionService!.callFunction(
        'auctionAddress', widget.auctionService!.auctionCreatorContract);
    widget.logger
        .d('Address of newly created auction is: ${res[0].toString()}');
    setState(() {
      widget.contractAddress = truncateEthAddress(res[0].toString());
    });
    await widget.auctionService!.deployAuctionContract(res[0].toString());
  }

  //TODO: ROWCELL DOESNT WORK - TEXTALIGN
  //TODO: statefulwidget loses state when hot reload - find out why. ContractAddress disappears but not auctionService
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    widget.auctionService = context.watch<AuctionService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction: ${widget.contractAddress}'),
      ),
      body: Column(children: [
        SizedBox(
          height: size.height * 0.05,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 5),
          ),
          child: Row(
            children: [
              const Text('Account:',
                  style: TextStyle(fontSize: 30, color: Colors.black)),
              const SizedBox(
                width: 20,
              ),
              Text(
                truncateEthAddress(widget.auctionService!.account),
                style: const TextStyle(fontSize: 20, color: Colors.blueAccent),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Place Bid'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Finalize Auction'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Cancel Auction'),
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
        AuctionTableOutput(
          rows: tableRows,
        ),
      ]),
    );
  }
}
