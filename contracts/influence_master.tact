import "@stdlib/ownable";
import "@stdlib/deploy";
import "./messages";
import "./fund";
import "./influence_wallet";

contract InfluenceMaster with Jetton {
    totalSupply: Int as coins;
    owner: Address;
    content: Cell;
    mintable: Bool;
    maxSupply: Int as coins; // Extract parameter we set here. The Jetton Standards doesn't have this parameter.
    fundSeqno: Int as uint256 = 0;
    init(content: Cell, maxSupply: Int){
        self.totalSupply = 0;
        self.owner = sender();
        self.mintable = true;
        self.content = content;
        self.maxSupply = maxSupply;
    }

    receive(){}

    receive(msg: Mint){
        let ctx: Context = context();
        // require(ctx.sender == self.owner, "Not Owner");
        // require(self.mintable, "Can't Mint Anymore");
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination)
    }

    receive("Mint: 100"){
        // Public Minting
        let ctx: Context = context();
        require(self.mintable, "Can't Mint Anymore");
        self.mint(ctx.sender, 100, self.owner); // 🔴
    }

    receive("Owner: MintClose"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not Owner");
        self.mintable = false;
    }

    receive("buy"){
        let ctx: Context = context();
        self.mint(ctx.sender, ctx.value, myAddress());
    }

    receive("fund"){
        let ctx: Context = context();
        self.fundSeqno = (self.fundSeqno + 1);
        //TODO: овнер фанда мастер или какой-то из наших кошелей
        let fundInit: StateInit = initOf FundContract(myAddress(), self.fundSeqno);
        let fundAddress: Address = contractAddress(fundInit);
        send(SendParameters{
                to: fundAddress,
                value: 0,
                bounce: true,
                mode: (SendRemainingValue + SendIgnoreErrors),
                data: fundInit.data,
                code: fundInit.code
            }
        );
    }

    get fun lastFundAddress(sender: Slice): Address {
        let init: StateInit = initOf FundContract(sender.loadAddress(), self.fundSeqno);
        return contractAddress(init);
    }
}
// ============================================================================================================ //
trait Jetton with Ownable, Deployable {
    totalSupply: Int; // Already set initially
    mintable: Bool;
    owner: Address;
    content: Cell;
    maxSupply: Int;
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");

    receive(msg: TokenUpdateContent){
        self.requireOwner(); // Allow changing content only by owner
        self.content = msg.content; // Update content
    }

    receive(msg: TokenBurnNotification){
        self.requireSenderAsWalletOwner(msg.response_destination); // Check wallet
        self.totalSupply = (self.totalSupply - msg.amount); // Update supply
        if (msg.response_destination != null) {
            // Cashback
            send(SendParameters{
                    to: msg.response_destination,
                    value: 0,
                    bounce: false,
                    mode: (SendRemainingValue + SendIgnoreErrors),
                    body: TokenExcesses{queryId: msg.queryId}.toCell()
                }
            );
        }
    }

    // Private Methods //
    // @to The Address receive the Jetton token after minting
    // @amount The amount of Jetton token being minted
    // @response_destination The previous owner address
     fun mint(to: Address, amount: Int, response_destination: Address) {
        // require(self.totalSupply + amount <= self.maxSupply, "The total supply will be overlapping.");
        self.totalSupply = (self.totalSupply + amount); // Update total supply

        let winit: StateInit = self.getJettonWalletInit(to); // Create message
        send(SendParameters{
                to: contractAddress(winit),
                //ОЛЕГ ВОТ ТУТ НАДО КАК_ТО ПОДУМАТЬ))) как корректно взять стоимость для транзы этой
                value: 0,
                bounce: true,
                mode: (SendRemainingValue + SendIgnoreErrors),
                body: TokenTransferInternal{
                    queryId: 0,
                    amount: amount,
                    from: myAddress(),
                    response_destination: response_destination,
                    forward_ton_amount: 0,
                    forward_payload: emptySlice()
                }.toCell(),
                code: winit.code,
                data: winit.data
            }
        );
    }

     fun msgValue(value: Int): Int {
        let msgValue: Int = value;
        let tonBalanceBeforeMsg: Int = (myBalance() - msgValue);
        let storageFee: Int = (self.minTonsForStorage - min(tonBalanceBeforeMsg, self.minTonsForStorage));
        msgValue = ((msgValue - storageFee) + self.gasConsumption);
        return msgValue;
    }

     fun requireSenderAsWalletOwner(owner: Address) {
        let ctx: Context = context();
        let winit: StateInit = self.getJettonWalletInit(owner);
        require(contractAddress(winit) == ctx.sender, "Invalid sender");
    }

    virtual fun getJettonWalletInit(address: Address): StateInit {
        return initOf InfluenceWallet(myAddress(), address, true, 0);
    }

    // ====== Get Methods ====== //

    get fun get_jetton_data(): JettonData {
        //TODO: хз можно ли здесь адреса мастера прокинуть
        //TODO: 0 - для инита жетон волета самого мастера
        let code: Cell = self.getJettonWalletInit(myAddress()).code;
        return
            JettonData{
                totalSupply: self.totalSupply,
                mintable: self.mintable,
                owner: self.owner,
                content: self.content,
                walletCode: code
            };
    }

    get fun get_wallet_address(owner: Address): Address {
        let winit: StateInit = self.getJettonWalletInit(owner);
        return contractAddress(winit);
    }
}