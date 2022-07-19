import 'package:auction_app/services/auction_service.dart';
import 'package:flutter/material.dart';

import '../utils/helper.dart';

class AuctionCreatePage extends StatefulWidget {
  final AuctionService auctionService;
  final String auctionAddress;
  const AuctionCreatePage({
    Key? key,
    required this.auctionService,
    required this.auctionAddress,
  }) : super(key: key);

  @override
  State<AuctionCreatePage> createState() => _AuctionCreatePageState();
}

class _AuctionCreatePageState extends State<AuctionCreatePage> {
  @override
  void initState()  {
    deployContract();
    super.initState();
  }

  void deployContract() async {
    await widget.auctionService.deployAuctionContract(widget.auctionAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction: ${widget.auctionAddress}'),
      ),
      body: Column(children: [
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
    );
  }
}
