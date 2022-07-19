import 'package:auction_app/services/auction_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../utils/helper.dart';

class AuctionCreatePage extends StatefulWidget {
  final AuctionService auctionService;
  final String createAuctionTransactionRef;
  late Logger logger;
  String contractAddress = '';
  AuctionCreatePage({
    Key? key,
    required this.auctionService,
    required this.createAuctionTransactionRef,
  }) : super(key: key);

  @override
  State<AuctionCreatePage> createState() => _AuctionCreatePageState();
}

class _AuctionCreatePageState extends State<AuctionCreatePage> {
  @override
  void initState() {
    super.initState();
    widget.logger = Logger();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deployContract();
    });
  }
  // this auctionservice doesn not work. We need to use it in the build method too
  void deployContract() async {
    List<dynamic> res = await widget.auctionService.callFunction(
        'auctionAddress', widget.auctionService.auctionCreatorContract);
    widget.logger
        .d('Address of newly created auction is: ${res[0].toString()}');
    setState(() {
      widget.contractAddress = truncateEthAddress(res[0].toString());
    });
    await widget.auctionService.deployAuctionContract(res[0].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction: ${widget.contractAddress}'),
      ),
      body: ChangeNotifierProvider.value(
        value: widget.auctionService,
        child: Column(children: [
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
                  truncateEthAddress(widget.auctionService.account),
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
        ]),
      ),
    );
  }
}
