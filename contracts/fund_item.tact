import "./messages";

contract FundItemContract {
    ownerFund: Address;
    description: String = "DESC";
    //TODO: везде добавить конкретный тип инта
    amount_to_help: Int = 0;
    current_amount: Int;
    title: String = "TITLE";
    deploy_time: Int as uint32;
    image_url: String = "IMG";
    seqno: Int;
    init(ownerFund: Address, seqno: Int){
        self.ownerFund = ownerFund;
        self.seqno = seqno;
        self.current_amount = 0;
        self.deploy_time = now();
    }

    receive(){}

    get fun data(): FundItemData {
        return
            FundItemData{
                ownerFund: self.ownerFund,
                description: self.description,
                amount_to_help: self.amount_to_help,
                current_amount: self.current_amount,
                title: self.title,
                deploy_time: self.deploy_time,
                image_url: self.image_url,
                seqno: self.seqno
            };
    }
}