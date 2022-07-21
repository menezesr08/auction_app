import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import '../credentials/wallet_connect_credentials.dart';
import '../utils/constants.dart';

class AuctionService extends ChangeNotifier {
  late WalletConnectEthereumCredentials credentials;
  late DeployedContract auctionCreatorContract;
  late DeployedContract auctionContract;
  late Web3Client client;
  late Logger logger;
  String account = '';
  List<String> bidders = [];
  Map<String, String> participantsAndBids = {};

  bool connected = false;
  String? sessionUrl;
  SessionStatus? session;

  AuctionService() {
    init();
  }

  Future<void> init() async {
    auctionCreatorContract = await loadContract(auctionCreatorAddress,
        'AuctionCreator', 'assets/auctionCreatorAbi.json');

    client = Web3Client(infuraUrl, Client());
    logger = Logger();
    logger.d('Initializing deployed contract, client and logger');
    logger.d(
        'Getting AuctionCreator contract: ${auctionCreatorContract.function('createAuction').name}');
  }

  Future<DeployedContract> loadContract(
      String address, String contractName, String abiPath) async {
    String abi = await rootBundle.loadString(abiPath);
    final contract = DeployedContract(ContractAbi.fromJson(abi, contractName),
        EthereumAddress.fromHex(address));

    return contract;
  }

  Future<void> walletConnect() async {
    logger.d('Connecting your wallet...');
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );

    connector.on('connect', (session) {
      logger.d('Connecting to WalletConnect bridge. Session details are: ');
      logger.d(session);
    });
    // this updates when you switch metamask accounts
    connector.on('session_update', (payload) {
      logger.d('Session is updating');
      WCSessionUpdateResponse res = payload as WCSessionUpdateResponse;
      account = res.accounts[0];
      notifyListeners();
    });
    connector.on('disconnect', (session) {
      logger.d('Session is disconnecting');
      connected = false;
      notifyListeners();
    });

    // Create a new session
    if (!connector.connected) {
      logger.d('Creating a new session on Metamask');
      session = await connector.createSession(
          chainId: 42,
          onDisplayUri: (uri) async {
            sessionUrl = uri;
            await launchUrl(Uri.parse(sessionUrl!));
          });
    }

    connected = true;

    account = session!.accounts[0];

    EthereumWalletConnectProvider provider =
        EthereumWalletConnectProvider(connector);
    credentials = WalletConnectEthereumCredentials(provider: provider);
    notifyListeners();
  }

  void _openMetamask() async {
    logger.d('Opening metamask...');
    await launchUrl(Uri.parse(sessionUrl!));
  }

  Future<List<dynamic>> callFunction(
      String functionName, DeployedContract contract, List params) async {
    final ethFunction = contract.function(functionName);
    final result = await client.call(
        contract: contract,
        function: ethFunction,
        params: params,
        sender: EthereumAddress.fromHex(account));

    return result;
  }

  Future<String> createAuctionContract() async {
    final res = await sendTransactionToFunction(
        'createAuction', auctionCreatorContract, null);
    logger.d('Newly created Auction address is: $res[0]');
    return res[0];
  }

  Future<void> deployAuctionContract(String contractAddress) async {
    auctionContract = await loadContract(
        contractAddress, 'Auction', 'assets/auctionAbi.json');
  }

  Future<String> sendTransactionToFunction(String functionName,
      DeployedContract contract, EtherAmount? amount) async {
    WalletConnectEthereumCredentials credentials = this.credentials;
    final ethFunction = contract.function(functionName);

    Transaction transaction = Transaction.callContract(
      from: EthereumAddress.fromHex(account),
      function: ethFunction,
      contract: contract,
      parameters: [],
      gasPrice: await client.getGasPrice(),
      value: amount,
      maxGas: null,
    );

    logger.d('Sending transaction...');
    _openMetamask();

    String result;
    try {
      result = await client.sendTransaction(
        credentials,
        transaction,
        fetchChainIdFromNetworkId: false,
        chainId: 42,
      );
      result = 'tx: $result';
      logger.d('Sent transaction with tx: $result');
    } catch (e) {
      logger.e('Transaction Failed. Message is: ${e.toString()}');
      result = e.toString();
    }

    logger.d('Send prize transaction hash is: $result');
    return result;
  }

  Future<String> placeBid(String value) async {
    EtherAmount amount = EtherAmount.fromUnitAndValue(EtherUnit.wei, value);
    final res =
        await sendTransactionToFunction('placeBid', auctionContract, amount);
    logger.d('Placed a bid. Transaction ref is: $res[0]');
    bidders.add(account);
    await fetchBids();
    return res[0];
  }

  Future<void> fetchBids() async {
    List totalTaskList = await callFunction('bidCount', auctionContract, []);
    logger.d('Number of bids: ${totalTaskList[0].toInt()}');

    int totalTaskLen = totalTaskList[0].toInt();
    participantsAndBids.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await callFunction('bids', auctionContract, [
        EthereumAddress.fromHex(bidders[i]),
      ]);
      // print('Id of each note is: ' + (temp[0] as BigInt).toString());
      participantsAndBids[bidders[i]] = temp[0].toString();
    }
    notifyListeners();
  }
}
