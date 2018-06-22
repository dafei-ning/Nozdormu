pragma solidity ^0.4.21;

contract Payroll {

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint Totalsalary = 0;

    uint constant payDuration = 10 seconds;
    address       owner;
    Employee[]    employees;
    event         log(string);

    function Payroll() {
        owner = msg.sender;
    }

    function _partialPaid(Employee empl) private{
        if(hasEnoughFund()){
            uint payment = empl.salary * (now - empl.lastPayday) / payDuration;
            empl.id.transfer(payment);
        }else{ revert();} //之前觉得不用require是为了省gas
    }

    function _findEmployee(address emplid) private returns (Employee, uint){
        for(uint i = 0; i < employees.length; i++){
            // if address exists, return info binding the address
            if(employees[i].id == emplid){
                return (employees[i], i);
            }
            // if it doesnt exist, it will return (0x0, 0, 0)
        }
    }
    
    function addEmployee(address emplid, uint sal){
    require(msg.sender == owner);
    var(checkempl, index) = _findEmployee(emplid);
    require(checkempl.id == 0x0);
    employees.push(Employee(emplid,sal * 1 ether,now));

    // 添加:
    Totalsalary += sal * 1 ether;
}

    function updateEmployee(address emplid, uint Sal) {
        require(msg.sender == owner);
        var(checkempl, index) = _findEmployee(emplid);
        require(checkempl.id != 0x0);
        _partialPaid(employees[index]);

        //添加：
        Totalsalary -= employees[index].salary;
        Totalsalary += Sal * 1 ether;

        employees[index].salary = Sal * 1 ether;
        employees[index].lastPayday = now;
        log("Employee info updated successfully");
        return;
    }

    function removeEmployee(address emplid){
        require(msg.sender == owner);
        var(checkempl, index) = _findEmployee(emplid);
        require(checkempl.id != 0x0);
        _partialPaid(employees[index]);

        //添加：
        Totalsalary -= employees[index].salary;

        delete employees[index];
        employees[index] = employees[employees.length -1];
        employees.length -= 1;
        return;
    }



    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / Totalsalary;
    }

    function hasEnoughFund() returns (bool) {
        return calculateRunway() >= 1;
    }

    function getPaid() {
        var(checkempl, index) = _findEmployee(msg.sender);
        require(checkempl.id != 0x0);
        uint nextPayday = checkempl.lastPayday + payDuration;

        if (nextPayday > now){revert();}

        require(hasEnoughFund());
        employees[index].lastPayday = nextPayday;
        employees[index].id.transfer(employees[index].salary);
    }

    
}



