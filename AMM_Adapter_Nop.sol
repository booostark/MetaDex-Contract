import "./openzeppelin/contracts/access/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
struct Temp_Token_Table_Element
{
    address token;
    uint256 amount;
    
}  
contract Meta_Dex_Adapter is Ownable
{
    event E_Log(string log);
    address m_AMM_Address;
  
    function  Process_On_Edge (Temp_Token_Table_Element [] memory token_registers,bytes calldata serialized_data
   
    ) external payable returns (Temp_Token_Table_Element [] memory res)
    {
        token_registers[0].amount=31415;
      
        emit E_Log("NOP");
        return token_registers;
    }
    
    
    
    fallback() external payable {}
    receive() external payable { 
   
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