import "./messages";
import "./influence_wallet";

contract FundContract {
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");
    fund_name: String = "NAME";
    description: String = "DESCRIPTION";
    image: String;
    owner: Address;
    item_seqno: Int as uint256;
    seqno: Int as uint256;
    init(owner: Address, seqno: Int){
        self.image = "IMAGE";
        self.owner = owner;
        self.seqno = seqno;
        self.item_seqno = 0;
    }

    receive(){
    }

    receive("item"){
        self.item_seqno = self.item_seqno + 1;
        let itemInit: StateInit = initOf InfluenceWallet(self.owner, myAddress(), self.item_seqno);
        // let destination: Address = contractAddress(itemInit);
        send(SendParameters{
                to: self.owner,
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors,
                body: Mint{
                    amount: ton("0.1"),
                    receiver: myAddress(),
                    seqno: self.item_seqno
                }.toCell(),
                data: itemInit.data,
                code: itemInit.code
            }
        );
    }

    get fun getAllItemsAddresses(): map<Int, Address>{
        let i: Int = 1;
        let addressesMap: map<Int, Address> = emptyMap();

        while(i <= self.item_seqno) {
            let itemAddress: Address = self.calculateItemAddress(i);
            addressesMap.set(i, itemAddress);

            i = i + 1;
        }

        return addressesMap;
    }

    get fun fund_data(): Fund {
        //TODO: сделать здесь без переменной а сразу возвращать, чтобы поля на фронте из стека парсились по порядку
        let res: Fund = Fund{
            balance: myBalance(),
            description: self.description,
            name: self.fund_name,
            //TODO: make a review of all redundant fields
            image: self.image,
            owner: self.owner,
            seqno: self.seqno,
            itemSeqno: self.item_seqno
        };
        return res;
    }

    fun calculateItemAddress(itemSeqno: Int): Address {
        let init: StateInit = initOf InfluenceWallet(self.owner, myAddress(), itemSeqno);
        return contractAddress(init);
    }

    get fun getItemAddress(itemSeqno: Int): Address {
        return self.calculateItemAddress(itemSeqno);
    }
}