    interface I_AMM_Adaptor
    {
        
    
    function Get_AMM_Address(address addr)external view returns  (address);
   
    function  Process_On_Edge (address amm_address,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
  

    function  getAmountsOut (address amm_address,uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function  getAmountsIn (address amm_address,uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
   
    }