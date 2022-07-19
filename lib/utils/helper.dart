// shortens ETH address to format 0x0000…0000
String truncateEthAddress(String address) {
  if (address.isEmpty) {
    return '';
  }
  const pattern = r"(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})";
  RegExp regexp = RegExp(pattern);
  final match = regexp.allMatches(address).first.group;
  return "${match(1)}…${match(2)}";
}