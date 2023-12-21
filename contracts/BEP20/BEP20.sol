// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBEP20.sol";

contract BEP20 is Ownable, IBEP20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view virtual override returns (uint256) {
        return _balances[_owner];
    }

    function getOwner() public view virtual override returns (address) {
        return owner();
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view virtual override returns (uint256 remaining) {
        remaining = _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(_from, spender, _value);
        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal virtual {
        require(_from != address(0), "BEP20: transfer from the zero");
        require(_to != address(0), "BEP20: transfer to the zero");

        _beforeTokenTransfer(_from, _to, _amount);

        uint256 fromBalance = _balances[_from];
        require(fromBalance >= _amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[_from] = fromBalance - _amount;
            _balances[_to] += _amount;
        }

        emit Transfer(_from, _to, _amount);

        _afterTokenTransfer(_from, _to, _amount);
    }

    function _mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "BEP20: mint to the zero");

        _beforeTokenTransfer(address(0), _account, _amount);

        _totalSupply += _amount;
        unchecked {
            _balances[_account] += _amount;
        }
        emit Transfer(address(0), _account, _amount);

        _afterTokenTransfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(_account, address(0), _amount);

        uint256 accountBalance = _balances[_account];
        require(accountBalance >= _amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[_account] = accountBalance - _amount;
            _totalSupply -= _amount;
        }

        emit Transfer(_account, address(0), _amount);

        _afterTokenTransfer(_account, address(0), _amount);
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal virtual {
        require(_owner != address(0), "BEP20: approve from the zero");
        require(_spender != address(0), "BEP20: approve to the zero");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function _spendAllowance(address _owner, address _spender, uint256 _amount) internal virtual {
        uint256 currentAllowance = allowance(_owner, _spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= _amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(_owner, _spender, currentAllowance - _amount);
            }
        }
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual {}

    function _afterTokenTransfer(address _from, address _to, uint256 _amount) internal virtual {}
}
