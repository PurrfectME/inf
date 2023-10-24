import "./messages";

contract FundContract {
    const minTonsForStorage: Int = ton("0.01");
    const gasConsumption: Int = ton("0.01");
    fund_name: String;
    description: String;
    balance: Int;
    image: String;
    owner: Address;
    init(fund_name: String, description: String, owner: Address){
        self.fund_name = fund_name;
        self.description = description;
        self.balance = 0;
        self.image = "ASD";
        self.owner = owner;
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