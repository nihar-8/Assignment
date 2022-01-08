import UIKit

//MARK: - EmployeeResponse
struct EmployeeResponse: Decodable
{
    var status: String?
    var data: [Employee]?
    var message: String?
}

//MARK: - Employee
struct Employee: Decodable
{
    var id: Int?
    var employeeName: String?
    var employeeSalary, employeeAge: Int?
    var profileImage: String?

    enum CodingKeys: String, CodingKey
    {
        case id
        case employeeName = "employee_name"
        case employeeSalary = "employee_salary"
        case employeeAge = "employee_age"
        case profileImage = "profile_image"
    }
}
