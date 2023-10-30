import "@stdlib/deploy";
import "./messages";
import "./fund_item";

contract FundContract with Deployable {
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");
    fund_name: String = "ASD";
    description: String = "ASD";
    balance: Int;
    image: String;
    owner: Address;
    item_seqno: Int as uint256 = 0;
    init(owner: Address, seqno: Int){
        self.balance = 0;
        self.image = "ASD";
        self.owner = owner;
        self.item_seqno = seqno;
    }

    receive(){}

    receive("item"){
        self.item_seqno = self.item_seqno + 1;
        let itemInit: StateInit = initOf FundItem(myAddress(), "desc", 100, "Petya", "url", self.item_seqno);
        send(SendParameters{
                to: contractAddress(itemInit),
                value: ton("0.02"),
                mode: SendIgnoreErrors,
                data: itemInit.data,
                code: itemInit.code
            }
        );
    }

    receive("new"){
        self.balance = 10;
    }

    get fun ownerFund(): Address {
        return self.owner;
    }

    get fun fund_data(): Fund {
        let res: Fund = Fund{
            balance: myBalance(),
            description: self.description,
            name: self.fund_name,
            jetton_balance: self.balance,
            image: self.image,
            owner: self.owner
        };
        return res;
    }
}