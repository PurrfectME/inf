message Donate {
    master: Address;
    amount: Int;
    responseDestination: Address;
}
message CreateFundItem {
    masterContract: Address;
}
struct JettonData {
    totalSupply: Int;
    mintable: Bool;
    owner: Address;
    content: Cell;
    walletCode: Cell;
}
struct FundItemData {
    ownerFund: Address;
    description: String;
    amount_to_help: Int;
    current_amount: Int;
    title: String;
    deploy_time: Int as uint32;
    image_url: String;
    seqno: Int;
}
message Mint {
    amount: Int;
    receiver: Address;
    // seqno: Int as uint256;
}
struct Fund {
    name: String;
    description: String;
    balance: Int as coins;
    image: String;
    owner: Address;
    seqno: Int;
    itemSeqno: Int;
}
struct JettonWalletData {
    balance: Int;
    owner: Address;
    master: Address;
    walletCode: Cell;
    // title: String;
    // isDonater: Bool;
    // seqno: Int;
    // description: String;
    // amountToHelp: Int;
    // currentAmount: Int;
    // deployTime: Int as uint32;
    // imageUrl: String;
}
struct ContentData {
    name: String;
    description: String;
    symbol: String;
    decimals: Int as uint32;
    image: String;
}
message(0xf8a7ea5) TokenTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    response_destination: Address;
    custom_payload: Cell?;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
    isDonate: Bool;
    itemSeqno: Int;
}
message(0x178d4519) TokenTransferInternal {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    response_destination: Address;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
}
message(0x7362d09c) TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
}
message(0x595f07bc) TokenBurn {
    queryId: Int as uint64;
    amount: Int as coins;
    response_destination: Address;
    custom_payload: Cell?;
}
message(0x7bdd97de) TokenBurnNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    response_destination: Address;
}
message(0xd53276db) TokenExcesses {
    queryId: Int as uint64;
}
message TokenUpdateContent {
    content: Cell;
}