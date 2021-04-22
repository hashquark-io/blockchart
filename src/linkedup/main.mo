import token "./token";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Cycles "mo:base/ExperimentalCycles";

 shared({caller =owner }) actor class Server (
   token_callee: Principal
 ){
   type UserId= Principal;
  private stable var initialized : Bool = false;

  private stable var token : actor {
            totalSupply: query () -> async Nat;
            name: query () -> async Text;
            getBalance: query () -> async Nat;
            deposit:(Principal) ->async ();
            balanceOf: (Principal)-> async Nat;
            outerCycles: ()-> async Nat;
            transfer_from_to: (Principal,Principal,Nat)-> async Bool;
         } = actor(Principal.toText(token_callee));

  initialized:=true;

  public  func getName(): async Text{
      assert(initialized);
      await token.name()
  };
    public  func getBalance(): async Nat{
      assert(initialized);
      await token.getBalance()
  };

    public  func getTotalSupply(): async Nat{
      assert(initialized);
      await token.totalSupply()
  };
      public  shared(msg) func deposit(balance: Nat): async (){
      assert(initialized);
      Cycles.add(balance);
      await token.deposit(msg.caller)
  };

  public shared(msg) func transfer_from_to(to:UserId,amount :Nat ): async Bool{
      assert(initialized);
      await token.transfer_from_to(msg.caller,to,amount)
  };
  public shared(msg) func getBalanceOf(id: UserId): async Nat {
             assert(initialized);
             await token.balanceOf(id)
  };

  public shared query(msg) func getOwnId(): async UserId { msg.caller };

  public shared(msg) func getOuterCycles(): async Nat {
          await token.outerCycles()
  };

  public shared query(msg) func getCyclesBalance(): async Nat{
      Cycles.balance()
  };
}