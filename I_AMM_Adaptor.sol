    interface I_AMM_Adaptor
    {
        
    
    function Get_AMM_Address(address addr)external view returns  (address);
   
    function  swapExactTokensForTokens (address amm_address,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
  
    
    
    function  swapExactTokensForETH (address amm_address,uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
   

    function  swapExactETHForTokens (address amm_address,uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    
    
    function  quote (address amm_address,uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
  
    function  getAmountOut (address amm_address,uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
   
    function  getAmountIn (address amm_address,uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
  
    function  getAmountsOut (address amm_address,uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function  getAmountsIn (address amm_address,uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
   
    }