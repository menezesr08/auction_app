import 'package:auction_app/pages/auction_create_page.dart';
import 'package:auction_app/services/auction_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AuctionService(),
    child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    ),
  ));
}

class HomePage extends StatefulWidget {
  bool isLoading = false;
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var auctionService = context.watch<AuctionService>();
    return Scaffold(
        backgroundColor: Colors.black38,
        appBar: AppBar(
          title: const Text('Auction App'),
        ),
        body: auctionService.connected
            ? Center(
                child: widget.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          await auctionService
                              .createAuctionContract()
                              .then((transactionRef) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AuctionCreatePage(
                                              createAuctionTransactionRef:
                                                  transactionRef,
                                            )),
                                  ));
                        },
                        child: const Text('Create Auction'),
                      ),
              )
            : Center(
                child: InkWell(
                  onTap: () async {
                    await auctionService.walletConnect();
                  },
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/metamask.png',
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Connect to Metamask',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
