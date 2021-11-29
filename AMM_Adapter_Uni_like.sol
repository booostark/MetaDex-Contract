import "./openzeppelin/contracts/access/Ownable.sol";
import "./openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IRouter{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
contract Meta_Dex_Adapter is Ownable
{
    address m_AMM_Address;
    function Set_AMM_Address(address addr)public onlyOwner
    {
        m_AMM_Address=addr;
    }
    function Get_AMM_Address(address addr)public view returns  (address)
    {
        return m_AMM_Address;
    }
    function  swapExactTokensForTokens (address amm_address,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts)
    {
        _safeTransferFrom(path[0],msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(amm_address,amountIn);
        
        return IRouter(amm_address).swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
    }
    
    
    function  swapExactTokensForETH (address amm_address,uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts)
    {
        _safeTransferFrom(path[0],msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(amm_address,amountIn);
        return IRouter(amm_address).swapExactTokensForETH(amountIn,amountOutMin,path,to,deadline);
    }

    function  swapExactETHForTokens (address amm_address,uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts)
    {
        
        //return IRouter(amm_address).swapExactETHForTokens(amountOutMin,path,to,deadline);
        
        bytes memory data=abi.encodeWithSelector(IRouter(amm_address).swapExactETHForTokens.selector,amountOutMin,path,to,deadline);
        (bool success, bytes memory returndata)=address(amm_address).call{value:msg.value}(data);
        require(success==true,"SWAP FAILED");
        uint[] memory amounts= abi.decode(returndata, (uint[]  ));
        
        return amounts;
    }
    
    function  quote (address amm_address,uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB)
    {
        return IRouter(amm_address).quote( amountA,  reserveA,  reserveB);
    }
    function  getAmountOut (address amm_address,uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut)
    {
         return IRouter(amm_address).getAmountOut( amountIn,  reserveIn,  reserveOut);
    }
    function  getAmountIn (address amm_address,uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn)
    {
         return IRouter(amm_address).getAmountIn( amountOut,  reserveIn,  reserveOut);
    }
    function  getAmountsOut (address amm_address,uint amountIn, address[] calldata path) external view returns (uint[] memory amounts)
    {
         return IRouter(amm_address).getAmountsOut( amountIn,path);
    }
    function  getAmountsIn (address amm_address,uint amountOut, address[] calldata path) external view returns (uint[] memory amounts)
    {
         return IRouter(amm_address).getAmountsIn( amountOut,  path);
    }
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts)
    {
        _safeTransferFrom(path[0],msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(m_AMM_Address,amountIn);
        
        return IRouter(m_AMM_Address).swapExactTokensForTokens(amountIn,amountOutMin,path,to,deadline);
    }
    
    
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts)
    {
        _safeTransferFrom(path[0],msg.sender,address(this),amountIn);
        IERC20(path[0]).approve(m_AMM_Address,amountIn);
        return IRouter(m_AMM_Address).swapExactTokensForETH(amountIn,amountOutMin,path,to,deadline);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts)
    {
        
        //return IRouter(m_AMM_Address).swapExactETHForTokens(amountOutMin,path,to,deadline);
        
        bytes memory data=abi.encodeWithSelector(IRouter(m_AMM_Address).swapExactETHForTokens.selector,amountOutMin,path,to,deadline);
        (bool success, bytes memory returndata)=address(m_AMM_Address).call{value:msg.value}(data);
        require(success==true,"SWAP FAILED");
        uint[] memory amounts= abi.decode(returndata, (uint[]  ));
        
        return amounts;
    }
    
    function quote(uint amountA, uint reserveA, uint reserveB) external view returns (uint amountB)
    {
        return IRouter(m_AMM_Address).quote( amountA,  reserveA,  reserveB);
    }
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut)
    {
         return IRouter(m_AMM_Address).getAmountOut( amountIn,  reserveIn,  reserveOut);
    }
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external view returns (uint amountIn)
    {
         return IRouter(m_AMM_Address).getAmountIn( amountOut,  reserveIn,  reserveOut);
    }
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts)
    {
         return IRouter(m_AMM_Address).getAmountsOut( amountIn,path);
    }
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts)
    {
         return IRouter(m_AMM_Address).getAmountsIn( amountOut,  path);
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