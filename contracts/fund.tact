import "@stdlib/deploy";
import "./messages";
import "./fund_item";

contract FundContract with Deployable {
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");
    fund_name: String = "NAME";
    description: String = "DESCRIPTION";
    balance: Int;
    image: String;
    owner: Address;
    item_seqno: Int as uint256 = 0;
    seqno: Int as uint256;
    init(owner: Address, seqno: Int){
        self.balance = 0;
        self.image = "IMAGE";
        self.owner = owner;
        self.seqno = seqno;
        self.item_seqno = 0;
    }

    receive(){}

    receive("item"){
        self.item_seqno = self.item_seqno + 1;
        let itemInit: StateInit = initOf FundItemContract(myAddress(), self.item_seqno);
        send(SendParameters{
                to: contractAddress(itemInit),
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors,
                data: itemInit.data,
                code: itemInit.code
            }
        );
    }

    receive("new"){
        self.balance = 10;
    }

    get fun lastItemAddress(): Address {
        let init: StateInit = initOf FundItemContract(myAddress(), self.item_seqno);
        return contractAddress(init);
    }

    get fun fund_data(): Fund {
        let res: Fund = Fund{
            balance: myBalance(),
            description: self.description,
            name: self.fund_name,
            jetton_balance: self.balance,
            image: self.image,
            owner: self.owner,
            seqno: self.seqno,
            itemSeqno: self.item_seqno
        };
        return res;
    }
}