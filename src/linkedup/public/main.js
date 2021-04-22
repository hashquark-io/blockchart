import $ from "jquery";
import  BigNumber from 'bignumber.js';
import { Principal ,IDL} from '@dfinity/agent';
// Make the LinkedUp app's public methods available locally
import linkedup from "ic:canisters/linkedup";
import linkedupAssest from "ic:canisters/linkedup_assets"
import chart from "ic:canisters/chart";

import {
  ownProfilePageTmpl,
  profilePageTmpl,
  searchResultsPageTmpl,
  leftMessageShow,
  rightMessageShow
} from "./templates";
import { injectHtml } from "./utils";

import "bootstrap/dist/css/bootstrap.min.css";
import "animate.css/animate.min.css";
import "./index.css";

window.$ = window.jQuery = $;
      // Reveal animations.
      // const wow = new WOW();
      // wow.init();
      linkedupAssest  
      .retrieve("index.html")
      .then(injectHtml)
      .then(() =>{    
        $(document).ready(function () {
    var start=false;
    var messageList =[];
    var currentMessageList=[];
    var timeId=null;
    var customerTimeId=null;
      const token_name=$("#token_name");
      const own_id =$("#own_id");
      const token_balance=$("#token_balance");
      const despoit =$("#despoit");
      const acount_balance=$("#acount_balance");
      const acount_cycles=$("#acount_cycles");
      const canister_cycles =$("#canister_cycles")
      const transfor_input =$("#transfor");
      const to_account =$("#to_account");
    
      const state = {
        connection: [],
        profile: {},
        results: [],
      };
   function deposit(){

        const value= despoit.val() * 1;
        console.log(value)
        if(!value || value <0){
          return alert("输入正确金额");
        }
        (async function(){
          let res=await linkedup.deposit(new BigNumber(value));
          console.log(res)
          clearContent();
          renderMain();
        })();
        
      }

      function transfor(){

        const value= transfor_input.val() * 1;
        const to =to_account.val();

        console.log(value)
        if(!value || value <0){
          return alert("输入正确金额");
        }
        if(!to){
          return alert("输入账户");  
        }
        (async function(){
          let res=await linkedup.transfer_from_to(Principal.fromText(to),new BigNumber(value));
          console.log(res)
          clearContent();
          renderMain();
        })();
        
      }

      const query_account =$("#query_account");
      const query_balance =$("#query_balance");

      function queryBalance(){
       const account = query_account.val();
       console.log(account);
       if(!account|| account.length ==0){
        return alert("输入账户");   
       }
       (async function(){
        let res=await linkedup.getBalanceOf(Principal.fromText(account));
        console.log(res);
        query_balance.val(res.toNumber());
      })();
        
      }
      function clearContent(){  
        token_name.text("");
        own_id.text("");
        token_balance.text("");
        acount_balance.text("");
        acount_cycles.text("");
        canister_cycles.text("")
      }
 
      //
      // function renderNavbar() {
      //   const navbar = $(".navbar-custom");
      //   if (navbar.width() < 576) {
      //     navbar.addClass("collapse-custom");
      //   } else {
      //     navbar.removeClass("collapse-custom");
      //   }
      // }

      function renderMain(){
        (async function () {
          Promise.all([linkedup.getName(),
            linkedup.getOwnId(),
            linkedup.getBalance(),
            linkedup.getCyclesBalance(),
            linkedup.getOuterCycles()
          ]).then(async (data)=>{
            console.log(data);
            const [name,ownId,tokenBalance,acountCycles,canisterCycles] =data;
            token_name.text(name);
           token_balance.text(tokenBalance);
           acount_cycles.text(acountCycles);
           canister_cycles.text(canisterCycles)
           const acountBalance = await linkedup.getBalanceOf(ownId);
           acount_balance.text(acountBalance);
           own_id.text(ownId);
           state.profile={
            name,
            ownId,
            tokenBalance,
            acountCycles,
            acountBalance,
            canisterCycles,
            to:state.profile.to
           }
          })
       
        })();
      };
    const chartFrame =$("#chart_frame");
    const conect_btn =$("#conect_btn");
    const chart_id=$("#chart_id");
    const connect_account =$("#connect_account");
    const chart_history =$("#chart_history");
    var show =false;
     function connect(){
       show =!show;
       if(show) {
        const to_account_id =chart_id.val();
        if(!to_account_id || to_account_id.length ==0){
         return alert("输入聊天账户");  
        } 
        state.profile['to']=to_account_id;
         conect_btn.text("断开");
         connect_account.text(to_account_id);
         startCustomerShow();
         timeId=  setInterval(readMessage,1000);
       }else{
         conect_btn.text("链接");
         timeId&&clearInterval(timeId);
         customerTimeId&& clearInterval(customerTimeId);
         clearCustomerShow();
         connect_account.text("");
         state.profile['to']=null;
       }
     }

     function clearCustomerShow(){
      currentMessageList=[];
      chart_history.html("");
     }
     function startCustomerShow(){
      customerTimeId =setInterval(()=>{
        var fragment=document.createDocumentFragment();
        var i =null;
        while (i=messageList.shift()){
          console.log("消息:",i)
          let node = i.id.toText() != state.profile.ownId.toText() ?$(rightMessageShow(i))[0]:$(leftMessageShow(i))[0] ;
          fragment.appendChild(node)
          if(currentMessageList.length > 50){
            currentMessageList.shift().remove();
          }
          currentMessageList.push(node)
        }
        chart_history.append(fragment)
        
      },1);

     }
     function readMessage(){
       console.log("来自",state.profile['to'])
      chart.receiveMessage(Principal.fromText(state.profile['to'])).then(messages=>{
        messageList=messageList.concat(messages);
      })

     }
     const sendContent =$("#send_content");

     function sendMessage(){
        let content= sendContent.val();
        if(!content||content.length ==0){
          console.error("消息发送不能为空")
          return alert("消息内容不能为空")
        }
        if(!state.profile.ownId){
          return alert("系统加载中请稍后")
        }
        if(!state.profile.to){
          return alert("请选择要发送消息的用户")
        }
          let message ={
            id: state.profile.ownId,
            content: content
          }
          messageList.push({
            id:  state.profile.ownId,
            content: content
          });
          chart.sendMessage(Principal.fromText(state.profile['to']),message).then(()=>{   
            console.log("发送完毕");

          })
          
     }
      renderMain();
      function disableSubmitButton(btn) {
        btn.prop("disabled", true);
        btn.empty();
        btn.append('<i class="fa fa-cog fa-spin"></i> Wait...');
      }

      // Enable submit button.
      function enableSubmitButton(btn, phrase) {
        btn.empty();
        btn.append(phrase);
        btn.prop("disabled", false);
      }

      function clearAdminSections() {
        $(".profile").hide();
        $(".search").hide();
        $(".connections").hide();
      }

      function  renderOwnProfile() {

        (async function () {
          try {
            const ownId = await chart.getOwnId();
            const data = await chart.get(ownId);
            data.connections = [];
            $(".profile").html(ownProfilePageTmpl(data)).show();
            // data.connections = await chart.getConnections(ownId);
            // state.connections = data.connections;
            // $(".profile").html(ownProfilePageTmpl(data)).show();
          } catch (err) {
            console.error(err);
          }
        })();
      }

      function renderProfile(userId) {
        clearAdminSections();
        (async function () {
          try {
            let data = await chart.get(userId);
            state.profile = data;
            data.connections = [];
            data.isConnected = true;
            $(".profile").html(profilePageTmpl(data)).show();
            Promise.all([
              chart.isConnected(userId),
              chart.getConnections(userId),
            ]).then(([isConnected, connections]) => {
              data.isConnected = isConnected;
              data.connections = connections;
              $(".profile").html(profilePageTmpl(data)).show();
            });
          } catch (err) {
            console.error(err);
          }
        })();
      }

      function renderEdit(userId) {
        clearAdminSections();
        $(".edit").show().find("#first-name").focus();

        (async function () {
          let result = {};
          if (userId) {
            result = await linkedup.get(userId);
          }
          updateForm(result);
        })();
      }

      function renderSearch(term) {
        clearAdminSections();

        (async function () {
          try {
            const results = await linkedup.search(term);
            state.results = results;
            $(".search").html(searchResultsPageTmpl(results)).show();
          } catch (err) {
            console.error(err);
          }
        })();
      }

      function renderConnections(userId) {
        clearAdminSections();
        $(".connections").show();

        (async function () {
          const ownId = linkedup.getOwnId();
          let connections = userId
            ? await linkedup.getConnections(userId)
            : await linkedup.getConnections(ownId);
          let message;
          if (connections.length) {
            message = connections.map((profile) => searchResultTmpl(profile));
          } else {
            message = "<div>You don't have any connections yet.";
          }
          $(".connections-list").html(message);
        })();
      }
      const showEdit = () => {
        renderEdit();
      };

      const connectWith = (userId) => {
        try {
          const profile = state.profile;
          linkedup.connect(profile.id);
          renderOwnProfile();
        } catch (err) {
          console.error(err);
        }
      };
       const image=$("#imgUrl");
       var imageData=null;
      function tranforImageData(){
        const reader = new FileReader()
       
        reader.onload=function(e){
          console.log(reader.result)
           
          imageData=    new TextDecoder().decode(new Uint8Array(reader.result))
      }
      reader.readAsArrayBuffer( image[0].files[0])

      }

      function createUser(){
        // const button = $(this).find('button[type="submit"]');
        // disableSubmitButton(button);

        const firstName = $(this).find("#first-name").val();
        const lastName = $(this).find("#last-name").val();
        const title = $(this).find("#title").val();
        const company = $(this).find("#company").val();
        const experience = $(this).find("#experience").val();
        const education = $(this).find("#education").val();
       console.log("上传");
        async function action() {
          // Call Profile's public methods without an API
          await chart.create({
            firstName,
            lastName,
            title,
            company,
            experience,
            education,  
            imgUrl:imageData,
          });
          imageData =null;
          renderOwnProfile();
          // enableSubmitButton(button, "Submit");
        }
        action();

      }
      const showProfile = (index) => {
        const profile = state.results[index];
        renderProfile(profile.id);
      };

      const search = () => {
        const searchInputEl = document.getElementById("search");
        renderSearch(searchInputEl.value);
      };

      window.actions = {
        connectWith,
        showProfile,
        search,
        showEdit,
        deposit,
        transfor,
        queryBalance,
        connect,
        sendMessage,
        createUser,
        tranforImageData
      };
    })
    })
  

