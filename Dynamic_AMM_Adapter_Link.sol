import "./openzeppelin/contracts/access/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract Dynamic_AMM_Adapter_Link is Ownable
{
    mapping(string => address) public m_Adaptor_Address;
    mapping(string => address) public m_AMM_Address;
    address public m_WETH;
    
    function Set_Adaptor(string memory name ,address adaptor_addr,address amm_addr) public  onlyOwner
    {
        m_Adaptor_Address[name]=adaptor_addr;
        m_AMM_Address[name]=amm_addr;
    }
    
    function Get_Adaptor(string memory name) public  view returns(address,address )
    {
        return ( m_Adaptor_Address[name],m_AMM_Address[name]);
    }
    function Get_WETH()public  view returns(address)
    {
       return m_WETH;
    }
    function Set_WETH(address weth)public  onlyOwner
    {
        m_WETH=weth;
    }
}