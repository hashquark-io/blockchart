import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Hash "mo:base/Hash";
import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type Message =Types.Message;
  type UserId = Types.UserId;
  type MessageBuffer=Buffer.Buffer<Message>;

  public class Directory() {
    // The "database" is just a local hash map
   let  hashMap = HashMap.HashMap<UserId, Profile>(1, isEq, Principal.hash);

    public func createOne(userId: UserId, profile: NewProfile) {
      hashMap.put(userId, makeProfile(userId, profile));
    };

    public func updateOne(userId: UserId, profile: Profile) {
      hashMap.put(userId, profile);
    };

    public func findOne(userId: UserId): ?Profile {
      hashMap.get(userId)
    };

    public func findMany(userIds: [UserId]): [Profile] {
      func getProfile(userId: UserId): Profile {
        Option.unwrap<Profile>(hashMap.get(userId))
      };
      Array.map<UserId, Profile>(userIds, getProfile)
    };

    public func findBy(term: Text): [Profile] {
      var profiles: [Profile] = [];
      for ((id, profile) in hashMap.entries()) {
        let fullName = profile.firstName # " " # profile.lastName;
        if (includesText(fullName, term)) {
          profiles := Array.append<Profile>(profiles, [profile]);
        };
      };
      profiles
    };

    // Helpers

    func makeProfile(userId: UserId, profile: NewProfile): Profile {
      {
        id = userId;
        firstName = profile.firstName;
        lastName = profile.lastName;
        title = profile.title;
        company = profile.company;
        experience = profile.experience;
        education = profile.education;
        imgUrl = profile.imgUrl;
      }
    };

    func includesText(string: Text, term: Text): Bool {
      let stringArray = Iter.toArray<Char>(string.chars());
      let termArray = Iter.toArray<Char>(term.chars());

      var i = 0;
      var j = 0;

      while (i < stringArray.size() and j < termArray.size()) {
        if (stringArray[i] == termArray[j]) {
          i += 1;
          j += 1;
          if (j == termArray.size()) { return true; }
        } else {
          i += 1;
          j := 0;
        }
      };
      false
    };
  };


    func makeMessage(userId: UserId, content: Text): Message {
      {
        id = userId;
        content =content;
      }
    };
  public class MessagePool(){
       var  hashMap = HashMap.HashMap<UserId, MessageBuffer>(1, isEq, Principal.hash);

  public func createOne(useId:UserId,message: Message) {
          assert(hashMap.size() < 100);
          switch (hashMap.get(useId)){
            case (?messages){
              messages.add(message);
            };
            case (null){
             let queues=Buffer.Buffer<Message>(1);
             queues.add(message);
             hashMap.put(useId,queues);
            };
          };
    };

  public func cutomerBtach(userId: UserId,form: UserId ): async [Message]{
   var messages: MessageBuffer= Buffer.Buffer<Message>(1);
   var remainBuffer: MessageBuffer =Buffer.Buffer<Message>(1);
   let queues= Option.get<MessageBuffer>(hashMap.get(userId),Buffer.Buffer<Message>(1));
          
    for(message in queues.clone().vals()){
        if (message.id == form ) {
              messages.add(message);
              }else{
          remainBuffer.add(message);
              };
      };
   let prev= hashMap.replace(userId,remainBuffer);
      messages.toArray()
  };

 
};

 func isEq(x: UserId, y: UserId): Bool { x == y };
};