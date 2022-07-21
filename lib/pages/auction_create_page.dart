import 'package:auction_app/services/auction_service.dart';
import 'package:auction_app/widgets/auction_table_output.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final numberController = TextEditingController();

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

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
        'auctionAddress', widget.auctionService!.auctionCreatorContract, []);
    widget.logger
        .d('Address of newly created auction is: ${res[0].toString()}');
    setState(() {
      widget.contractAddress = truncateEthAddress(res[0].toString());
    });
    await widget.auctionService!.deployAuctionContract(res[0].toString());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    widget.auctionService = context.watch<AuctionService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction: ${widget.contractAddress}'),
      ),
      backgroundColor: Colors.black38,
      body: Column(children: [
        SizedBox(
          height: size.height * 0.05,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 5),
          ),
          child: Row(
            children: [
              const Text('Account:',
                  style: TextStyle(fontSize: 30, color: Colors.blueAccent)),
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
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.red),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[.0-9]'))
                    ]),
              ),
            ),
            TextButton(
              onPressed: () async {
                await widget.auctionService?.placeBid(
                  numberController.text.trim(),
                );
              },
              child: const Text('Place Bid'),
            ),
          ],
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
