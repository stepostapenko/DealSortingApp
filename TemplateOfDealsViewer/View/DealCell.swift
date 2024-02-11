import UIKit

class DealCell: UITableViewCell {
    static let reuseIidentifier = "DealCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var instrumentNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var sideLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(with deal: Deal, dateFormatter: DateFormatter) {
        instrumentNameLabel.text = deal.instrumentName
        priceLabel.text = (round(deal.price * 100) / 100).description
        amountLabel.text = round(deal.amount).description
        dateLabel.text = dateFormatter.string(from: deal.dateModifier)
        
        switch deal.side {
        case .buy: priceLabel.textColor = .systemGreen
        case .sell: priceLabel.textColor = .systemRed
        }
        sideLabel.text = deal.side.description
    }
    
}
