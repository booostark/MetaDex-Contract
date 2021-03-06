
import "./openzeppelin/contracts/access/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./openzeppelin/contracts/utils/math/SafeMath.sol";

struct Temp_Token_Table_Element
{
    address token;
    uint256 amount;
    
}  

interface I_AMM_Adaptor
{
    

function Get_AMM_Address(address addr)external view returns  (address);

function  Process_On_Edge (Temp_Token_Table_Element[]memory token_registers ,bytes calldata serialized_data
   
) external payable returns (uint[] memory amounts);


function  getAmountsOut (address amm_address,uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

function  getAmountsIn (address amm_address,uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}
struct Process_Instruction
{
    string amm_name;
    bytes serialized_data;
    
}
struct Reunite_Process
{
    
    Temp_Token_Table_Element[] temp_token_table_register;
    Process_Instruction[] instructions;
    
}
interface I_Dynamic_AMM_Adapter_Link
{
    function Get_Adaptor(string memory name) external  view returns(address,address);

}
contract Reunite_AMM  is Ownable
{
    using SafeMath for uint;
    address public m_Dynamic_AMM_Adapter_Link;
    function Set_Dynamic_AMM_Adapter_Link(address addr)public onlyOwner
    {
        m_Dynamic_AMM_Adapter_Link=addr;
    }
    
    function Process(Reunite_Process calldata  args)public payable returns(Temp_Token_Table_Element[] memory res)
    {
        Temp_Token_Table_Element[] memory token_registers=new Temp_Token_Table_Element[](args.temp_token_table_register.length);
       
      
        for(uint i=0;i<args.instructions.length;i++)
        {
         token_registers= Process_One_Instruction(token_registers,args.instructions[i]);
       
            
        }
        return token_registers;
        
        
    }
    
    function Process_One_Instruction(Temp_Token_Table_Element[]memory token_registers , Process_Instruction memory args )public payable returns (Temp_Token_Table_Element[]memory )
    {
        
        address t_adaptor;
        address t_amm;
        
        
        (t_adaptor,t_amm)=I_Dynamic_AMM_Adapter_Link(m_Dynamic_AMM_Adapter_Link).Get_Adaptor(args.amm_name);
        bytes memory data=abi.encodeWithSelector(I_AMM_Adaptor(t_adaptor).Process_On_Edge.selector,token_registers ,args.serialized_data);
        (bool success, bytes memory returndata) = address(t_adaptor).delegatecall(data);
        require(success==true,"SafeERC20: ERC20 operation did not succeed");
        Temp_Token_Table_Element[]memory res =abi.decode(returndata, (Temp_Token_Table_Element[]));
        
        return res;
    }
    
    
    
    
    function Receive_Token(address addr,uint256 value,address from) private returns(uint256)
    {
        
        if(addr==address(0))
        {
            return 0;
        }
        
        uint256 t_balance_old = IERC20(addr).balanceOf(address(this));
        _safeTransferFrom(addr,from, address(this),value);
        uint256 t_balance = IERC20(addr).balanceOf(address(this));
        
        uint256 e_amount=t_balance.sub(t_balance_old);
        
        return e_amount;
        
    }
    
    function _safeTransfer(address token, address to, uint256 value) private  {
        _callOptionalReturn(token, abi.encodeWithSelector(IERC20(token).transfer.selector, to, value));
    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) private  {
        _callOptionalReturn(token, abi.encodeWithSelector(IERC20(token).transferFrom.selector, from, to, value));
    }
    
    function safeTransfer(address token, address to, uint256 value) public onlyOwner {
        _callOptionalReturn(token, abi.encodeWithSelector(IERC20(token).transfer.selector, to, value));
    }
    function safeTransferFrom(address token, address from, address to, uint256 value) public onlyOwner {
        _callOptionalReturn(token, abi.encodeWithSelector(IERC20(token).transferFrom.selector, from, to, value));
    }
    function Call_Function(address addr,uint256 value ,bytes memory data) public payable onlyOwner {
      addr.call{value:value}(data);
    }
    function _callOptionalReturn(address token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success==true,"SafeERC20: ERC20 operation did not succeed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    
    
}
