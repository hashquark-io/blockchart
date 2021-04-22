import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Cycles "mo:base/ExperimentalCycles";

shared(msg)  actor class Token(_name: Text, _symbol: Text, _decimals: Nat, _totalSupply: Nat, capacity: Nat) {
    private stable var initialized : Bool = false;
      stable var store_balances : [(Principal, Nat)] = [];

    // Before upgrade, we must dump all player data to stable accounts.
    system func preupgrade() {
        store_balances := Iter.toArray(balances.entries());
    };

    private stable var name_ : Text = _name;
    private stable var decimals_ : Nat = _decimals;
    private stable var symbol_ : Text = _symbol;
    
    private stable var totalSupply_ : Nat = _totalSupply;

      private stable var balance = 0;

    private var balances =  HashMap.fromIter<Principal,Nat>(
        Iter.map<(Principal,Nat),(Principal,Nat)>(store_balances.vals(),func ((id, balance)) { (id, balance)}),store_balances.size(),func (x, y) { x == y }, Principal.hash
    );
    private var allowances = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Nat>>(1, Principal.equal, Principal.hash);
        // balances.put(msg.caller, totalSupply_);
        initialized := true;


    // public shared(msg) func initialize(_name: Text, _symbol: Text, _decimals: Nat, _totalSupply: Nat) : async Bool {
    //     assert(initialized == false);
    //     name_ := _name;
    //     symbol_ := _symbol;
    //     decimals_ := _decimals;
    //     totalSupply_ := _totalSupply;
    //     balances.put(msg.caller, totalSupply_);
    //     initialized := true;
    //     return true;
    // };

    public shared(msg) func transfer(to: Principal, value: Nat) : async Bool {
        assert(initialized);
        switch (balances.get(msg.caller)) {
            case (?from_balance) {
                if (from_balance >= value) {
                    var from_balance_new = from_balance - value;
                    var to_balance_new = switch (balances.get(to)) {
                        case (?to_balance) {
                            to_balance + value;
                        };
                        case (_) {
                            value;
                        };
                    };
                    assert(from_balance_new <= from_balance);
                    assert(to_balance_new >= value);
                    balances.put(msg.caller, from_balance_new);
                    balances.put(to, to_balance_new);
                    return true;
                } else {
                    return false;
                };
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func transfer_from_to(from: Principal,to: Principal, value: Nat) : async Bool {
        assert(initialized);
        switch (balances.get(from)) {
            case (?from_balance) {
                if (from_balance >= value) {
                    var from_balance_new = from_balance - value;
                    var to_balance_new = switch (balances.get(to)) {
                        case (?to_balance) {
                            to_balance + value;
                        };
                        case (_) {
                            value;
                        };
                    };
                    assert(from_balance_new <= from_balance);
                    assert(to_balance_new >= value);
                    balances.put(from, from_balance_new);
                    balances.put(to, to_balance_new);
                    return true;
                } else {
                    return false;
                };
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func transferFrom(from: Principal, to: Principal, value: Nat) : async Bool {
        assert(initialized);
        switch (balances.get(from), allowances.get(from)) {
            case (?from_balance, ?allowance_from) {
                switch (allowance_from.get(msg.caller)) {
                    case (?allowance) {
                        if (from_balance >= value and allowance >= value) {
                            var from_balance_new = from_balance - value;
                            var allowance_new = allowance - value;
                            var to_balance_new = switch (balances.get(to)) {
                                case (?to_balance) {
                                   to_balance + value;
                                };
                                case (_) {
                                    value;
                                };
                            };
                            assert(from_balance_new <= from_balance);
                            assert(to_balance_new >= value);
                            allowance_from.put(msg.caller, allowance_new);
                            allowances.put(from, allowance_from);
                            balances.put(from, from_balance_new);
                            balances.put(to, to_balance_new);
                            return true;                            
                        } else {
                            return false;
                        };
                    };
                    case (_) {
                        return false;
                    };
                }
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func approve(spender: Principal, value: Nat) : async Bool {
        assert(initialized);
        switch(allowances.get(msg.caller)) {
            case (?allowances_caller) {
                allowances_caller.put(spender, value);
                allowances.put(msg.caller, allowances_caller);
                return true;
            };
            case (_) {
                var temp = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
                temp.put(spender, value);
                allowances.put(msg.caller, temp);
                return true;
            };
        }
    };

    public query func balanceOf(who: Principal) : async Nat {
        switch (balances.get(who)) {
            case (?balance) {
                return balance;
            };
            case (_) {
                return 0;
            };
        }
    };

    public query func allowance(owner: Principal, spender: Principal) : async Nat {
        switch(allowances.get(owner)) {
            case (?allowance_owner) {
                switch(allowance_owner.get(spender)) {
                    case (?allowance) {
                        return allowance;
                    };
                    case (_) {
                        return 0;
                    };
                }
            };
            case (_) {
                return 0;
            };
        }
    };

    public  shared(msg) func deposit(who: Principal) : async () {
    let amount = Cycles.available();
    let limit = capacity - balance;
    let acceptable =
      if (amount <= limit) amount
      else limit;
    let accepted = Cycles.accept(acceptable);
    assert (accepted == acceptable);
    balance += acceptable;
    var to_balance_new = switch (balances.get(who)) {
                        case (?to_balance) {
                            to_balance + acceptable;
                        };
                        case (_) {
                            acceptable;
                        };
                    };
     assert(to_balance_new >= acceptable);
     balances.put(who,to_balance_new);                
  };

  public shared(msg) func withdraw(amount : Nat)
    : async () {
    assert (amount <= balance);
    var _token_balance=  switch (balances.get(msg.caller)) {
                        case (?token_balance) {
                           token_balance
                        };
                        case (_) {
                          0
                        };
     };
      assert(amount <=_token_balance );
      assert(amount <= balance);
    Cycles.add(amount);
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
    let refund = Cycles.refunded();
    balance -= amount - refund;
  };

    public query func totalSupply() : async Nat {
        return totalSupply_;
    };

    public query func name() : async Text {
        return name_;
    };

    public query func decimals() : async Nat {
        return decimals_;
    };

    public query func symbol() : async Text {
        return symbol_;
    };

    public query func outerCycles() : async Nat {
        return Cycles.balance()
    };
    // Return the principal of the message caller/user identity
    public shared(msg) func callerPrincipal() : async Principal {
        return msg.caller;
    };

     public shared(msg) func getBalance() : async Nat {
    return balance;
  };


};