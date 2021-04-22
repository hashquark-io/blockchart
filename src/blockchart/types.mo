import Principal "mo:base/Principal";
import Blob "mo:base/Blob";

module {
  public type UserId = Principal;

  public type NewProfile = {
    firstName: Text;
    lastName: Text;
    title: Text;
    company: Text;
    experience: Text;
    education: Text;
    imgUrl: Text;
  };

  public type Profile = {
    id: UserId;
    firstName: Text;
    lastName: Text;
    title: Text;
    company: Text;
    experience: Text;
    education: Text;
    imgUrl: Text;
  };



  public type Message={
    id: UserId;
    content: Text;
  }
};
