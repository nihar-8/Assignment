import UIKit
import Alamofire
import SVProgressHUD

class ViewController: UIViewController
{
    //MARK: - Outlets
    @IBOutlet weak var employeesTable: UITableView!
    @IBOutlet weak var noDataFound: UILabel!
    
    //MARK: - Variables
    var employeeList = [Employee]()
    var id_list = [Int]()
    
    //MARK: = ViewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.fetchEmployeeList()
    }
    
    //MARK: - FetchEmployeeList
    func fetchEmployeeList()
    {
        self.showProgressHUD()
        AF.request("http://dummy.restapiexample.com/api/v1/employees", parameters: nil, headers: nil).validate(statusCode: 200 ..< 299).response
        { fetchedData in
            if let statusCode = fetchedData.response?.statusCode, statusCode == 429
            {
                self.showError("Too many requests. Please try again after sometime.")
            }
            else if let employeeData = fetchedData.data
            {
                if let employees = try? JSONDecoder().decode(EmployeeResponse.self, from: employeeData)
                {
                    if let status = employees.status, status == "success"
                    {
                        if let empList = employees.data
                        {
                            self.hideProgressHUD()
                            self.employeeList = empList.sorted(by: { $0.employeeName ?? "" < $1.employeeName ?? ""})
                            self.employeesTable.reloadData()
                        }
                    }
                    else
                    {
                        self.showError("Something went wrong. Please try again.")
                    }
                }
                else
                {
                    self.showError("Something went wrong. Please try again.")
                }
            }
            else
            {
                self.showError("Something went wrong. Please try again.")
            }
        }
    }
    
    //MARK: - ShowAlert
    func showError(_ message: String)
    {
        self.hideProgressHUD()
        let alert = UIAlertController(title: "Error!!!", message: message , preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default)
        { action in
            self.fetchEmployeeList()
        }
        alert.addAction(retryAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - ShowProgressHUD
    func showProgressHUD()
    {
        SVProgressHUD.show(withStatus: "Loading")
    }

    //MARK: - HideProgressHUD
    func hideProgressHUD()
    {
        SVProgressHUD.dismiss()
    }
    
    //MARK: - Show Names of Selected List
    @IBAction func showSelectedList(_ sender: UIButton)
    {
        var message = ""
        if self.id_list.count == 0
        {
            message = "No employees selected yet."
        }
        for id in self.id_list
        {
            if let emp = self.employeeList.filter({ $0.id == id }).first, let empName = emp.employeeName
            {
                message = message + "\n" + empName
            }
        }
        let alert = UIAlertController(title: "Selected Employees", message: message , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Employee Name Clicked
    @objc func employeeNameClicked(_ sender: EmployeeNameTapRecognizer)
    {
        if let selectedId = sender.employeeId
        {
            if let index = self.id_list.firstIndex(of: selectedId)
            {
                self.id_list.remove(at: index)
            }
            else
            {
                self.id_list.append(selectedId)
            }
            self.employeesTable.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController : UITableViewDataSource, UITableViewDelegate
{
    //TODO: Set the number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.noDataFound.isHidden = (self.employeeList.count != 0)
        self.employeesTable.isHidden = (self.employeeList.count == 0)
        return self.employeeList.count
    }
    
    //TODO: Configuration of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") as! EmployeeCell
        let employee = self.employeeList[indexPath.row]
        cell.myView.layer.borderColor = UIColor.systemIndigo.cgColor
        cell.myView.layer.borderWidth = CGFloat(1)
        cell.myView.layer.cornerRadius = CGFloat(10)
        cell.nameLabel.text = employee.employeeName
        cell.salaryLabel.text = "\(employee.employeeSalary ?? 0)"
        cell.selectedSymbol.layer.cornerRadius = CGFloat(5)
        cell.selectedSymbol.isHidden = (self.id_list.firstIndex(of: (employee.id ?? 0)) == nil)
        let tapGesture = EmployeeNameTapRecognizer(target: self, action: #selector(self.employeeNameClicked))
        tapGesture.employeeId = employee.id
        cell.nameLabel.addGestureRecognizer(tapGesture)
        return cell
    }
    
    //TODO: To add or remove id from selected list
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedEmployee = self.employeeList[indexPath.row]
        if let selectedId = selectedEmployee.id
        {
            if let index = self.id_list.firstIndex(of: selectedId)
            {
                self.id_list.remove(at: index)
            }
            else
            {
                self.id_list.append(selectedId)
            }
            self.employeesTable.reloadData()
        }
    }
}
