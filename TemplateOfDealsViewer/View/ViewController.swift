import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var sortOrderButton: UIBarButtonItem?
    private var sortTypeButton: UIBarButtonItem?
    
    private let presenter = DealSortingsPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Deals"
        configNavbar()
        presenter.subscribe { [weak self] in
            guard let this = self else { return }
            this.tableView.reloadData()
        }
    
        tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
        tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configNavbar() {
        sortTypeButton = UIBarButtonItem()
        var actions: [UIAction] = []
        for type in SortInfo.DealSortingType.allCases {
            actions.append(UIAction(title: type.description) { [self] (_) in
                sortTypeButton?.title = type.description
                presenter.sort(type: type)
            })
        }
        
        let menu = UIMenu(children: actions)
        sortTypeButton?.title = presenter.sortInfo.type.description
        sortTypeButton?.menu = menu
        navigationItem.rightBarButtonItem = sortTypeButton
        
        sortOrderButton = UIBarButtonItem(image: UIImage(systemName: presenter.sortInfo.order.sortOrderSystemImage),
                                          style: .plain, target: self,
                                          action: #selector(changeSortOrder))
        navigationItem.leftBarButtonItem = sortOrderButton
    }

    @objc private func changeSortOrder() {
        presenter.changeSortOrder()
        sortOrderButton?.image = UIImage(systemName: presenter.sortInfo.order.sortOrderSystemImage)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as! DealCell
        let deal = presenter.model[indexPath.row]
        cell.configCell(with: deal, dateFormatter: presenter.formatter)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as! HeaderCell
        return cell
    }
}
