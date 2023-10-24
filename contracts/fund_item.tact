struct FundItemData {
    fund_address: Address;
    description: String;
    amount_to_help: Int;
    current_amount: Int;
    title: String;
    deploy_time: Int as uint32;
    image_url: String;
    seqno: Int;
}

contract FundItem {
    fund_address: Address;
    description: String;
    //TODO: везде добавить конкретный тип инта
    amount_to_help: Int;
    current_amount: Int;
    title: String;
    deploy_time: Int as uint32;
    image_url: String;
    seqno: Int;
    init(fund_address: Address, description: String, amount_to_help: Int, title: String, image_url: String, seqno: Int){
        self.fund_address = fund_address;
        self.description = description;
        self.amount_to_help = amount_to_help;
        self.current_amount = 0;
        self.title = title;
        self.deploy_time = now();
        self.image_url = image_url;
        self.seqno = seqno;
    }

    get fun item_data(): FundItemData {
        return
            FundItemData{
                fund_address: self.fund_address,
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