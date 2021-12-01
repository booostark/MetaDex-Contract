
import "./openzeppelin/contracts/access/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./openzeppelin/contracts/utils/math/SafeMath.sol";
import "./I_AMM_Adaptor.sol";
struct Temp_Token_Table_Element
{
    address token;
    uint256 amount;
    
}
struct Process_Instruction
{
    string amm_name;
    uint256 token_index_from;
    address [] path;
    uint256 token_index_to;
    address receiver;
    
    uint256 numerator;
    uint256 denominator;
    
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
    
    function Process(Reunite_Process calldata  args)public payable
    {
        Temp_Token_Table_Element[] memory token_registers=new Temp_Token_Table_Element[](args.temp_token_table_register.length);
        uint256 token_received=0;
        for(uint i=0;i<args.temp_token_table_register.length;i++)
        {
            if(args.temp_token_table_register[i].amount>0 && args.temp_token_table_register[i].token!=address(0))
            {
                token_received= Receive_Token(args.temp_token_table_register[i].token,args.temp_token_table_register[i].amount,msg.sender);
                token_registers[i].amount=token_received;
            }
            token_registers[i].token=args.temp_token_table_register[i].token;
        }
        uint256 t_amountIn;uint256 received_ammount_from_amm;
        for(uint i=0;i<args.instructions.length;i++)
        {
            ( t_amountIn, received_ammount_from_amm)=Process_One_Instruction(token_registers,args.instructions[i]);
            token_registers[args.instructions[i].token_index_from].amount=token_registers[args.instructions[i].token_index_from].amount.sub(t_amountIn);
            token_registers[args.instructions[i].token_index_to].amount=token_registers[args.instructions[i].token_index_to].amount.add(received_ammount_from_amm);
            
            
            //I_AMM_Adaptor(t_adaptor).
            
        }
        
        
    }
    
    function Process_One_Instruction(Temp_Token_Table_Element[]memory token_registers , Process_Instruction memory args )public payable returns (uint256 ,uint256)
    {
        uint t_amountIn;
        uint t_amountOutMin=0;

        
        address t_to;
        uint t_deadline;
        
        
        address t_adaptor;
        address t_amm;
        
        uint256 t_token_index_from;
        uint256 t_token_index_to;
        (t_adaptor,t_amm)=I_Dynamic_AMM_Adapter_Link(m_Dynamic_AMM_Adapter_Link).Get_Adaptor(args.amm_name);
        t_token_index_from=args.token_index_from;
        t_token_index_to=args.token_index_to;
        t_amountIn=token_registers[t_token_index_from].amount;
        t_amountIn=t_amountIn.mul(args.numerator);
        t_amountIn=t_amountIn.div(args.denominator);
        

        t_deadline=block.timestamp+30;
        t_to=args.receiver;
        bytes memory data=abi.encodeWithSelector(I_AMM_Adaptor(t_adaptor).swapExactTokensForTokens.selector, t_amm,t_amountIn, t_amountOutMin,args.path,t_to,t_deadline);
        (bool success, bytes memory returndata)=address(t_adaptor).delegatecall(data);
        uint[]memory received_ammount_from_amm= abi.decode(returndata, (uint[]));
        return (t_amountIn,received_ammount_from_amm[received_ammount_from_amm.length-1]);
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
