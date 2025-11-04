/* Copyright 2023 Google LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

let adStatus;

function sendJson(request_ob,handleResponse){
    let request_json = JSON.stringify(request_ob);
    
    $.post('api',
        request_json,
        function(data, status, xhr) {
            handleResponse(JSON.parse(data));//= ;
        }
    )
    .fail(function(jqxhr, settings, ex) { alert('failed, ' + ex); });
}
/*
 * This is the primary handler for sendJson handleResponse
 * You can use other handlers if you like
 */
function handleGenericDemoResponse(reply){
    document.getElementById("i_return").innerHTML=returnTidyJSONfromBase64(reply.data);
    document.getElementById("o_return").innerHTML=returnTidyJSONfromBase64(reply.result);
}

// function to tidy up JSON before displaying it on the page
function returnTidyJSONfromBase64(base64){
    let str = JSON.stringify(atob(base64), null, 4).replace(/\\n/g, '<br>').replace(/\\"/g, '"').replace(/  /g, '&nbsp;&nbsp;&nbsp;&nbsp;').replace(/\\/g, '');
    return str.substring(1,str.length-1)+"<br>";
}

// Input / Output toggling and management
function toggleIO(i_or_o){
    let element = document.getElementById(i_or_o+"_button");
    let content_show_button = `
    <button type="button" class="btn btn-success" onClick="toggleIO('`+i_or_o+`');">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-bar-down" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M1 3.5a.5.5 0 0 1 .5-.5h13a.5.5 0 0 1 0 1h-13a.5.5 0 0 1-.5-.5zM8 6a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 0 1 .708-.708L7.5 12.293V6.5A.5.5 0 0 1 8 6z"></path>
        </svg>
        `+i_or_o+` Data
    </button>
    `;
    let content_hide_button = `
    <button type="button" class="btn btn-warning" onClick="toggleIO('`+i_or_o+`');">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-bar-up" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M8 10a.5.5 0 0 0 .5-.5V3.707l2.146 2.147a.5.5 0 0 0 .708-.708l-3-3a.5.5 0 0 0-.708 0l-3 3a.5.5 0 1 0 .708.708L7.5 3.707V9.5a.5.5 0 0 0 .5.5zm-7 2.5a.5.5 0 0 1 .5-.5h13a.5.5 0 0 1 0 1h-13a.5.5 0 0 1-.5-.5z"/>
        </svg>
        `+i_or_o+` Data
    </button>
    `;
    if(i_or_o=="Request"){
        if(request_io_visible){
            element.innerHTML=content_hide_button;
            request_io_visible=false;
            document.getElementById("i_return").style.display="none";
        }
        else{
            element.innerHTML=content_show_button;
            request_io_visible=true;
            document.getElementById("i_return").style.display="block";
        }
    }
    else{
        if(response_io_visible){
            element.innerHTML=content_hide_button;
            response_io_visible=false;
            document.getElementById("o_return").style.display="none";
        }
        else{
            element.innerHTML=content_show_button;
            response_io_visible=true;
            document.getElementById("o_return").style.display="block";
        }
    }
}

let request_io_visible = true;
let response_io_visible = true;
let io_area = `
<h5 align="center">I/O</h5>
    <section class="pb-4">
        <div class="bg-white border rounded-5">
            <div id="Request_button">
                <button type="button" class="btn btn-success" onClick="toggleIO('Request');">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-bar-down" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M1 3.5a.5.5 0 0 1 .5-.5h13a.5.5 0 0 1 0 1h-13a.5.5 0 0 1-.5-.5zM8 6a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 0 1 .708-.708L7.5 12.293V6.5A.5.5 0 0 1 8 6z"></path>
                    </svg>
                    Request Data
                </button>
            </div>
            <code id="i_return" class="small" style="display:block;">No data yet, try making a request<br><br></code><br>
            <div id="Response_button">
                <button type="button" class="btn btn-success" onClick="toggleIO('Response');">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-bar-down" viewBox="0 0 16 16">
                        <path fill-rule="evenodd" d="M1 3.5a.5.5 0 0 1 .5-.5h13a.5.5 0 0 1 0 1h-13a.5.5 0 0 1-.5-.5zM8 6a.5.5 0 0 1 .5.5v5.793l2.146-2.147a.5.5 0 0 1 .708.708l-3 3a.5.5 0 0 1-.708 0l-3-3a.5.5 0 0 1 .708-.708L7.5 12.293V6.5A.5.5 0 0 1 8 6z"></path>
                    </svg>
                    Response Data
                </button>
            </div>
            <code id="o_return" class="small" style="display:block;">No data yet, try making a request<br><br></code><br>
        </div>
    </section>
`;

/*
 * START UI Header Handlers
 */

function addHeaderItem(id,href,title){
    $('#header ul').append('<li class="nav-item"><a href="'+href+'" class="nav-link" id="'+id+'">'+title+'</a></li>');
}

function deselectAllHeaders(){
    document.getElementById('nav_home').classList.remove('active');
    document.getElementById('nav_enterprise').classList.remove('active');
    document.getElementById('nav_AD').classList.remove('active');
    document.getElementById('nav_annotation').classList.remove('active');
    document.getElementById('nav_pld').classList.remove('active');
    document.getElementById('nav_app_info').classList.remove('active');
}

function makeHeader(){
    let infoSvg = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"currentColor\" class=\"bi bi-info-circle\" viewBox=\"0 0 16 16\"><path d=\"M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z\"/><path d=\"m8.93 6.588-2.29.287-.082.38.45.083c.294.07.352.176.288.469l-.738 3.468c-.194.897.105 1.319.808 1.319.545 0 1.178-.252 1.465-.598l.088-.416c-.2.176-.492.246-.686.246-.275 0-.375-.193-.304-.533L8.93 6.588zM9 4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"/></svg>";
    $('body').prepend('<header class="d-flex flex-wrap justify-content-center py-3 mb-4 border-bottom" id="header"></header>');
    $('#header').append('<a href="/" class="d-flex align-items-center mb-3 mb-md-0 me-md-auto text-dark text-decoration-none"><span class="fs-4">RCE Demos</span>&nbsp;&nbsp;&nbsp;&nbsp;<span class="fs-6">Signed in as: '+username+'</span></a>');
    $('#header').append('<ul class="nav nav-pills"></ul>');
    addHeaderItem("nav_home","javascript:setPage('home')","Home");
    addHeaderItem("nav_enterprise","javascript:setPage('enterprise')","Enterprise");
    addHeaderItem("nav_annotation","javascript:setPage('annotation')","Annotation API");
    addHeaderItem("nav_AD","javascript:setPage('AD')","Account Defender");
    addHeaderItem("nav_pld","javascript:setPage('pld')","Password Leak");
    addHeaderItem("nav_app_info","javascript:setPage('appinfo')",infoSvg)
    $('#header').append('<div id="style_holder"></div>');
    if(firstLoad) { 
        makeLandingPage();
    }
}

function highlighter(i_o,regex){
    let str = document.getElementById(i_o).innerHTML;
    if(str.match(regex)){        
        let search = str.match(regex)[0];
        let out = str.replace(search,"<span class=\"highlight\">"+search+"</span>");
        document.getElementById(i_o).innerHTML=out;
    }
}

function startLoader(placeholder){
    document.getElementById(placeholder).style.display="block";
}

function stopLoader(placeholder){
    setTimeout(function(){
        document.getElementById(placeholder).style.display="none";
    }
    ,1000);
}

/*
 * END UI Header Handlers
 */

/*
 * START App Info content handling
 */

function makeAppInfoPage(){
    deselectAllHeaders();
    document.getElementById('nav_app_info').classList.add('active');

    sidebarItems = [
        ["app_info_detail","App Info", "javascript:;"]
    ];
    makeSideBar(sidebarItems); 
    showAppInfoPage();
}

function showAppInfoPage(){
    recreatePageWireframe();
    recreateInnerContentWireframe("App Info");
    document.getElementById("I_O").remove();
    document.getElementById("spacer").remove();
    putAppInfoContents();
}

function handleDbUpdateResponse(reply){
    console.log(atob(reply.status));
}

function handleContainerRestartResponse(reply){
    console.log(atob(reply.stretch_and_vern));
    stopLoader("restart_loader");
    document.getElementById("restart").innerHTML="<a href=\"javascript:location.reload();\">Refresh window</a>";
}



function putAppInfoContents(){
    $('#contentpanel').append('<div><p><small>Last build time: '+lastBuild+' ('+commitId+') <br><div id="restart_loader" style="display:none" class="loader"></div></p></div>');
}


/*
 * END App Info content handling
 */

/*
 * START Home/Landing
 */

let firstLoad = true;

function makeLandingPage(){
    firstLoad=false;
    nukePageContents();
    destroySidebar();
    document.getElementById("style_holder").innerHTML="<style>.grecaptcha-badge { visibility: visible; }</style>";
    $('#wrapper').append('<div id="content"></div>');
    deselectAllHeaders();
    document.getElementById('nav_home').classList.add('active');
    recreateInnerContentWireframe("reCAPTCHA Enterprise Demo");
    let landing_content = `
    <section class="pb-4">
        <div class="bg-white border rounded-5">
            <section class="w-100 p-4 d-flex justify-content-center pb-4">
                <p>All demo's built from documentation found at: <a href="https://cloud.google.com/recaptcha-enterprise/docs/how-to">https://cloud.google.com/recaptcha-enterprise/docs/how-to</a>.</p>
            </section>
        </div>
    </section>
    `;
    $('#contentpanel').append(landing_content);
}

/*
 * END Home/Landing
 */


/*
 *  START Enterprise Demo Page content
 */

function handleEnterpriseDemoResponse(reply){
    document.getElementById("i_return").innerHTML=returnTidyJSONfromBase64(reply.data);
    document.getElementById("o_return").innerHTML=returnTidyJSONfromBase64(reply.result);
    //highlighter("o_return",/"tokenProperties"(.|\n)*?},/);
    //highlighter("o_return",/"riskAnalysis"(.|\n)*?},/);
}

function doEnterpriseDemo(subtype,action){
    let site_key = v3_site_key; //assume v3 or no-image
    if(subtype=="test2"){
        site_key = test_0_2_site_key;
    }
    else if(subtype=="test8"){
        site_key = test_0_8_site_key;
    }
    else if(subtype=="v2"){
        site_key = v2_site_key;
    }    
    if(subtype=="v2"){
        if(grecaptcha.enterprise.getResponse(widgetResult)!=""){
            let request_ob = {
                type: "recap",
                subtype: subtype,
                token: grecaptcha.enterprise.getResponse(widgetResult),
                action: action
            };                 
            sendJson(request_ob,handleEnterpriseDemoResponse);
        }
        else{
            alert("You must complete the CAPTCHA");
        }
    }
    else{
        grecaptcha.enterprise.ready(function() {
            grecaptcha.enterprise.execute(site_key, {action: action}).then(function(token) {
                let recapToken = token.toString();
                let request_ob = {
                    type: "recap",
                    subtype: subtype,
                    token: recapToken,
                    action: action
                };                 
                sendJson(request_ob,handleEnterpriseDemoResponse);
            });
        });        
    }
}

function doExpressDemo(verdict){
    let request_ob = {
        type: "express",
        subtype: verdict,
        token: "empty",
        action: "empty"
    };                 
    sendJson(request_ob,handleEnterpriseDemoResponse);
}

function makeEnterprisePage(){
    deselectAllHeaders();
    document.getElementById('nav_enterprise').classList.add('active');
    sidebarItems = [
        ["nav_ent_v3","Score based", "javascript:showEnterprisePage('v3')"],
        ["nav_ent_test2","Test 0.2", "javascript:showEnterprisePage('test2')"],
        ["nav_ent_test8","Test 0.8", "javascript:showEnterprisePage('test8')"],
        ["nav_ent_noimage","No Image", "javascript:showEnterprisePage('noimage')"],
        ["nav_ent_v2","Visual Challenge", "javascript:showEnterprisePage('v2')"],
        ["nav_ent_express","Express", "javascript:showEnterprisePage('express')"]    
    ];
    makeSideBar(sidebarItems);
    recreateInnerContentWireframe("reCAPTCHA Enterprise");
    showEnterprisePage('v3');
}

function putEnterpriseDemoForm(type,action){
    $('#contentpanel').append('<div class="form-outline mb-4"><input type="email" id="email_addr" class="form-control" /><label class="form-label" for="email_addr">Email address</label></div>');
    $('#contentpanel').append('<div class="form-outline mb-4"><input type="password" id="passw" class="form-control" /><label class="form-label" for="passw">Password</label></div>');
    $('#contentpanel').append('<div class="row mb-4"><div class="col d-flex justify-content-center"><div class="form-check"><input class="form-check-input" type="checkbox" value="" id="remember" checked /><label class="form-check-label" for="remember"><small>Remember me</small></label></div></div>');
    $('#contentpanel').append('<div class="col"><a href="mfa.php"><small>Forgot password?</small></a></div></div>');
    $('#contentpanel').append('<div id="v2_checkbox_placeholder"></div>');
    $('#contentpanel').append('<div id="noimage_terms" style="display:none"><p class="small">This site is protected by reCAPTCHA Enterprise and<br>the Google <a href="https://policies.google.com/privacy">Privacy Policy</a> and <a href="https://policies.google.com/terms">Terms of Service</a> apply.</p></div>');
    if(type!="express"){
        $('#contentpanel').append('<button type="button" class="btn btn-primary btn-block mb-4" onClick="doEnterpriseDemo(\''+type+'\',\''+action+'\');" align="center">Sign in</button>');
    }
    else{
        $('#contentpanel').append('<button type="button" class="btn btn-primary btn-block mb-4" onClick="doExpressDemo(\'good\');" align="center">Good Visitor</button> &nbsp; ');
        $('#contentpanel').append('<button type="button" class="btn btn-primary btn-block mb-4" onClick="doExpressDemo(\'bad\');" align="center">Bad Visitor</button>');
    }    
    $('#contentpanel').append('<div class="text-center"><p>Not a member? <a href="javascript:alert(\'Not implemented in demo\');">Register</a></p></div>');
}

function removeEnterpriseSiteKeys(){
    if($('#recap').length>0){
        $('#recap').remove;
    }
}

function enterpriseSwitchSiteKeys(type){
    removeEnterpriseSiteKeys();
    if(type=="test2"){
        $('head').append("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+test_0_2_site_key+"\"></script>");
    }
    else if(type=="test8"){
        $('head').append("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+test_0_8_site_key+"\"></script>");
    }
    else if(type=="v2"){
        $('head').append("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+v2_site_key+"\"></script>");
    }
    else if(type=="trusted"){
        $('head').append("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+trusted_site_key+"\"></script>");
    }
    else{
        $('head').append("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+v3_site_key+"\"></script>");
    }
}

function showEnterprisePage(type){
    if($('#noimage_terms').length>0){
        document.getElementById("noimage_terms").style.display="none";
    }
    inactiveAllSidebar(sidebarItems);
    document.getElementById('nav_ent_'+type).classList.add('active');
    recreatePageWireframe();    

    if(type=="v3"){
        recreateInnerContentWireframe("Score Based");
        putEnterpriseDemoForm(type,"v3_login");
    }
    else if(type=="test2"){
        recreateInnerContentWireframe("Test Key Score: 0.2");
        enterpriseSwitchSiteKeys(type);
        putEnterpriseDemoForm(type,"v3_test2");
    }
    else if(type=="test8"){
        recreateInnerContentWireframe("Test Key Score: 0.8");
        enterpriseSwitchSiteKeys(type);
        putEnterpriseDemoForm(type,"v3_test8");
    }
    else if(type=="noimage"){
        recreateInnerContentWireframe("Inline Terms");
        putEnterpriseDemoForm(type,"v3_noimage");
        document.getElementById("noimage_terms").style.display="block"; 
        document.getElementById("style_holder").innerHTML="<style>.grecaptcha-badge { visibility: hidden; }</style>";
    }
    else if(type=="v2"){
        recreateInnerContentWireframe("Visual Challenge");
        putEnterpriseDemoForm(type,"v2_login");
        removeEnterpriseSiteKeys();
        visualOnloadCallback();
    }
    else if(type=="express"){
        recreateInnerContentWireframe("Express Integration");
        //enterpriseSwitchSiteKeys(type);
        putEnterpriseDemoForm(type,"express");
    }
}

let widgetResult = "";

function visualOnloadCallback() {
    widgetResult = grecaptcha.enterprise.render('v2_checkbox_placeholder', {
        'sitekey' : v2_site_key,
        'action' : 'v2_login'
    });
 };
/*
 *  END Enterprise Demo Page content
 */

/* 
 * START AD Page handling
 */

let adAnnoateAssessmentId,shortAssessmentId;

// might not be needed if changes can be coded into the API
function handleAdDemoResponse(reply){
    document.getElementById("i_return").innerHTML=returnTidyJSONfromBase64(reply.data);
    document.getElementById("o_return").innerHTML=returnTidyJSONfromBase64(reply.result);
    highlighter("i_return",/user_info.*?}<br>}<br><br>/); 
    highlighter("o_return",/risk_analysis.*?<br>}<br>/);
    highlighter("o_return",/account_defender_assessment.*?<br>}<br>/);

    tmpReplyResult = atob(reply.result);
    adAnnoateAssessmentId=atob(reply.result).substring(atob(reply.result).indexOf("projects/"),atob(reply.result).indexOf("\"\n"));
    shortAssessmentId=adAnnoateAssessmentId.substring(adAnnoateAssessmentId.lastIndexOf("/")+1,adAnnoateAssessmentId.length);
    
    document.getElementById("annotate_assessment_AD").innerHTML=`<p align="center">Annotate assessment <b><span id="assIdAd">`+shortAssessmentId+`</span></b></p>`+getAnnotationDropdownList("annotateAD");
}


function doAD(subtype){
    let site_key = v3_site_key; //assume v3 
    let action = "AD_"+subtype;
    if(subtype=="investigation"){
        let request_ob = {
            type: "AD",
            subtype: subtype,
            hashedAccountId: document.getElementById("hashedAccountId").value,
            action: action,
            token: ""
        };  
        sendJson(request_ob,handleGenericDemoResponse);
    }
    else{        
        grecaptcha.enterprise.ready(function() {
            if(action=="AD_creation"){action="signup";}
            grecaptcha.enterprise.execute(site_key, {action: action}).then(function(token) {
                let recapToken = token.toString();       
                let request_ob = {
                    type: "AD",
                    subtype: subtype,
                    hashedAccountId: userId,
                    action: action,
                    token: recapToken
                };        
                sendJson(request_ob,handleAdDemoResponse);
                
            });
        }); 
    }           
}

function randUserId(){
    return Math.floor(Math.random() * (9999999 - 1000000) + 1000000).toString(16).replace(".","");
}

let userId=randUserId();
let refreshIconSvg = '<svg data-icon-name="refreshIcon" viewBox="0 0 24 24" width="24" height="24" aria-hidden="true" sandboxuid="2"><path fill-rule="evenodd" d="M17.64 6.35A7.958 7.958 0 0011.99 4C7.57 4 4 7.58 4 12s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08a5.99 5.99 0 01-5.65 4c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L12.99 11h7V4l-2.35 2.35z" sandboxuid="2"></path></svg>';

function changeUserId(){
    userId=randUserId();
    document.getElementById("uid").innerHTML=userId+refreshIconSvg;
}

function annotateAD(annotation,reason){
    let request_ob = {
        type: "annotation",
        annotation: annotation,
        reason: reason,
        assessment_id: shortAssessmentId
    };  
    sendJson(request_ob,handleAnnotationResponse);
    document.getElementById("annotate_assessment_AD").innerHTML="Annotated "+shortAssessmentId;    
}

function putAdDemoForm(type,action){
    $('#contentpanel').append('<div id="div_normal_msg" style="display: block;"><p align="center">Thank you for logging into this site user '+username+' with user id <a href=# id="uid" alt="update" onClick="changeUserId();">'+userId+refreshIconSvg+'</a>. You are now logged in from <span class="highlight" id="location">somewhere near Genuine Location</span>.</p></div>');
    $('#contentpanel').append('<input type="hidden" id="hashedAccountId" value="'+userId+'">');
    $('#contentpanel').append('<div id="check_visitor_button" style="display:block;"><p align="center">Get account defender to check this visit?<br><button type="button" class="btn btn-primary btn-block mb-4" onclick="nuke_I_O();doAD(\''+type+'\');" align="center">Check Visitor</button></p></div>');
    $('#contentpanel').append('<div id="annotate_assessment_AD" style="display:block;"></div>');    
}

function showAdPage(type){
    inactiveAllSidebar(sidebarItems);
    document.getElementById('nav_AD_'+type).classList.add('active');
    recreatePageWireframe();
    recreateInnerContentWireframe("Account Defender");
    putAdDemoForm(type,"v3_login");
}

function makeAdPage(){
    deselectAllHeaders();
    document.getElementById('nav_AD').classList.add('active');
    sidebarItems = [
        ["nav_AD_normal","Account Defender", "javascript:showAdPage('normal')"]
    ];
    
    recreateInnerContentWireframe("Account Defender");
    if(adStatus){
        makeSideBar(sidebarItems);
        showAdPage('normal');
    }
    else{
        sidebarItems= [["nav_AD_off","Disabled", "javascript:showAdPage('off')"]];    
        makeSideBar(sidebarItems);
        showAdPage('off');
    }
}

/*
 * END AD Page handling
 */

/*
 * START Password Leak Detection handling
 */


function doPLD(checkScore){
    if(document.getElementById("username").value.length>0 && document.getElementById("password").value.length>0){
        document.getElementById("pld_result").innerHTML="Searching...";
        let site_key = v3_site_key; 
        grecaptcha.enterprise.execute(site_key, {action: "PLD"}).then(function(token) {
            let action = "PLD";
            let request_ob = {
                type: "PLD",
                subtype: "score",
                username: document.getElementById("username").value,
                password: document.getElementById("password").value,
                hashedAccountId: userId,
                action: action,
                token: token
            };  
            if(!checkScore){
                request_ob.subtype="standalone";
            }
            sendJson(request_ob,handlePLDDemoResponse);
        });
    }          
    else{
        document.getElementById("pld_result").innerHTML="You must enter a username and password";
    }
}

function handlePLDDemoResponse(reply){
    document.getElementById("i_return").innerHTML=returnTidyJSONfromBase64(reply.reply.data);
    document.getElementById("o_return").innerHTML=returnTidyJSONfromBase64(reply.reply.result);
    let leaked = reply.pldResult;
    if(leaked==true){
        document.getElementById("pld_result").innerHTML="Leaked!";
    }
    else{
        document.getElementById("pld_result").innerHTML="No leak found";
    }
    highlighter("i_return",/"private_password_leak_verification"(.|\n)*?}/);
    highlighter("o_return",/"privatePasswordLeakVerification"(.|\n)*?}/);
}

function putPLDDemoForm(){    
    $('#contentpanel').append('<form id="password_form"><div class="form-outline mb-4"><input type="email" id="username" value="" onClick="nuke_I_O();"><br><label class="form-label" for="uniqId">Email address/username</label></div><div class="form-outline mb-4"><input type="password" id="password" value="" onClick="nuke_I_O();"><br><label class="form-label" for="uniqId">Password</label></div>');
    $('#contentpanel').append('<div id="pld_button" style="display:block;" class="form-outline mb-4"><p align="center"><button type="button" class="btn btn-primary btn-block mb-4" onclick="nuke_I_O();doPLD(false);" align="center">Check Combination</button></p></div></form>');
    $('#contentpanel').append('<div id="pld_result" style="display:block"></div>');
}

function showPLDPage(type){
    inactiveAllSidebar(sidebarItems);
    document.getElementById('nav_pld_'+type).classList.add('active');
    if(type=="leak"){
        document.getElementById("username").value="leakedusername";
        document.getElementById("password").value="leakedpassword";
    }
    else if(type=="test"){
        document.getElementById("username").value="test";
        document.getElementById("password").value="password";        
    }
    else if(type=="admin"){
        document.getElementById("username").value="admin";
        document.getElementById("password").value="password";        
    }
    else if(type=="scott"){
        document.getElementById("username").value="scott";
        document.getElementById("password").value="tiger";        
    }
    else{
        document.getElementById("username").value="";
        document.getElementById("password").value="";        
    }
}

function makePLDPage(){
    deselectAllHeaders();
    document.getElementById('nav_pld').classList.add('active');
    if(adStatus){
        sidebarItems = [
            ["nav_pld_clear","clear form", "javascript:showPLDPage('clear')"],
            ["nav_pld_leak","leakedusername | leakedpassword", "javascript:showPLDPage('leak')"],
            ["nav_pld_test","test | password", "javascript:showPLDPage('test')"],
            ["nav_pld_admin","admin | password", "javascript:showPLDPage('admin')"],
            ["nav_pld_scott","scott | tiger", "javascript:showPLDPage('scott')"]
        ];
        makeSideBar(sidebarItems);
        recreateInnerContentWireframe("Password Leak Detection");
        putPLDDemoForm();
        showPLDPage('clear');
    }
    else{
        sidebarItems= [["nav_pld_off","Disabled", "javascript:showAdPage('off')"]];    
        makeSideBar(sidebarItems);
        recreateInnerContentWireframe("Enable Account Defender");
        inactiveAllSidebar(sidebarItems);
        document.getElementById('nav_pld_off').classList.add('active');
        $('#contentpanel').append('<div id="ad_is_off" style="display:block;">This part of the demo requires Account Defender to be enabled in the Google Cloud reCAPTCHA console settings; this is because Password Leak Detection is a sub feature of Account Defender. Please refresh the browser when the feature has completed being enabled.</div>');
    }
}

/*
 * END Password Leak Detection handling
 */

/*
 * START Annotation API handling
 */

function getAnnotationDropdownList(method){
    return `<div class="dropdown">
        <button type="button" id="dropdownMenuButton" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Annotate
        </button>
        <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
            <a class=\"dropdown-item\" href=\"javascript:`+method+`('LEGITIMATE','REASON_UNSPECIFIED');\">LEGITIMATE - REASON_UNSPECIFIED</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('LEGITIMATE','REFUND');\">LEGITIMATE - REFUND</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('LEGITIMATE','TRANSACTION_ACCEPTED');\">LEGITIMATE - TRANSACTION_ACCEPTED</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('LEGITIMATE','INITIATED_TWO_FACTOR');\">LEGITIMATE - INITIATED_TWO_FACTOR</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('LEGITIMATE','PASSED_TWO_FACTOR');\">LEGITIMATE - PASSED_TWO_FACTOR</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('LEGITIMATE','CORRECT_PASSWORD');\">LEGITIMATE - CORRECT_PASSWORD</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','REASON_UNSPECIFIED');\">FRAUDULENT - REASON_UNSPECIFIED</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','CHARGEBACK');\">FRAUDULENT - CHARGEBACK</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','CHARGEBACK_FRAUD');\">FRAUDULENT - CHARGEBACK_FRAUD</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','CHARGEBACK_DISPUTE');\">FRAUDULENT - CHARGEBACK_DISPUTE</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','REFUND_FRAUD');\">FRAUDULENT - REFUND_FRAUD</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','REFUND');\">FRAUDULENT - REFUND</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','TRANSACTION_DECLINED');\">FRAUDULENT - TRANSACTION_DECLINED</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','FAILED_TWO_FACTOR');\">FRAUDULENT - FAILED_TWO_FACTOR</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','INCORRECT_PASSWORD');\">FRAUDULENT - INCORRECT_PASSWORD</a>
            <a class=\"dropdown-item\" href=\"#" onclick=\"`+method+`('FRAUDULENT','SOCIAL_SPAM');\">FRAUDULENT - SOCIAL_SPAM</a>
        </div>
    </div>`;
}

function makeAnnotationPage(){
    deselectAllHeaders();
    document.getElementById('nav_annotation').classList.add('active');
    sidebarItems = [
        ["nav_annoation_generate","Generate", "javascript:getAnnotationAssesmentId();"]
    ];
    makeSideBar(sidebarItems);
    recreateInnerContentWireframe("Annotation API");
    document.getElementById("style_holder").innerHTML="<style>.grecaptcha-badge { visibility: hidden; }</style>";
    showAnnotationPage();
}

function showAnnotationPage(){
    inactiveAllSidebar(sidebarItems);
    document.getElementById('nav_annoation_generate').classList.add('active');
    putAnnoationDemoForm();
}

function putAnnoationDemoForm(){

   $('#contentpanel').append('<div id="annotation_api_form" style="display:block;"><p align="center">Annotate this assessment: <input type="text" id="annotationAssessmentId" value="" onClick="nuke_I_O();"><br><a href="#" onclick="nuke_I_O();getAnnotationAssesmentId();">Generate</a></p></div>');
   $('#contentpanel').append(getAnnotationDropdownList("doAnnotation"));
}

function getAnnotationAssesmentId(){
    grecaptcha.enterprise.ready(function() {
        grecaptcha.enterprise.execute(v3_site_key, {action: "generate_assessment"}).then(function(token) {
            let recapToken = token.toString();
            let request_ob = {
                type: "AD",
                subtype: "normal",
                hashedAccountId: userId,
                action: "generate_assessment",
                token: recapToken
            };                 
            sendJson(request_ob,handleAnnotationGetAssessmentResponse);
        });
    });
}

function handleAnnotationGetAssessmentResponse(reply){
    let ann64 = atob(reply.result);
    let name = ann64.substring(ann64.indexOf("assessments/")+12,ann64.indexOf("assessments/")+28);
    document.getElementById("annotationAssessmentId").value=name;
}

function doAnnotation(){
    let request_ob = {
        type: "annotation",
        annotation: "LEGITIMATE",
        reason: "REASON_UNSPECIFIED",
        assessment_id: document.getElementById("annotationAssessmentId").value
    };  
    sendJson(request_ob,handleAnnotationResponse);
}

function handleAnnotationResponse(reply){    
    document.getElementById("i_return").innerHTML=returnTidyJSONfromBase64(reply.data);
    document.getElementById("o_return").innerHTML=atob(reply.result);
}

/*
 * END Annotation API handling
 */


/*
 * START Page content handling
 */



function nuke_I_O(){
    if($('#I_O').length>0){
        $('#I_O').remove();
        $('#wrapper').append('<div id="I_O" class="container-sm"></div>');
        $('#I_O').append(io_area);
    }
}

function nukePageContents(){
    enterpriseSwitchSiteKeys("v3");
    if($('#content').length>0){
        $('#content').remove();
    }
    if($('#spacer').length>0){
        $('#spacer').remove();
    }
    if($('#I_O').length>0){
        $('#I_O').remove();
    }
}

function recreateInnerContentWireframe(title){
    $('#content').append('<h4 align="center"> '+title+'</h4>');
    $('#content').append('<section class="pb-4"><div class="bg-white border rounded-5"><section class="w-100 p-4 d-flex justify-content-center pb-4"><div id="contentpanel"></div></section></div></section>');
}

function recreatePageWireframe(){
    nukePageContents();
    document.getElementById("style_holder").innerHTML="<style>.grecaptcha-badge { visibility: visible; }</style>";
    $('#wrapper').append('<div id="content"></div>');
    $('#wrapper').append('<div id="spacer"></div>');    
    $('#wrapper').append('<div id="I_O" class="container-sm"></div>');
    $('#I_O').append(io_area);

}

function setPage(page){
    recreatePageWireframe();
    if(page=="enterprise"){
        makeEnterprisePage();
    }
    else if(page=="AD"){
        makeAdPage();
    }
    else if(page=="annotation"){
        makeAnnotationPage();
    }
    else if(page=="pld"){
        makePLDPage();
    }
    else if(page=="appinfo"){
        makeAppInfoPage();
    }
    else{
        makeLandingPage();
    }
}

/*
 * END Page content handling
 */

/*
 * START SIDEBAR CODE
 */

let sidebarItems = null;

function inactiveAllSidebar(sidebarItems){
    for (let i = 0; i < sidebarItems.length; i++) {
        document.getElementById(sidebarItems[i][0]).classList.remove('active');
    }
}

function destroySidebar(){
    if($('#sidebar').length>0){
        $('#sidebar').remove();
    }
}

function addSidebarItem(id,title,action){
    $('#sidebar ul').append('<li><a href="#" class="nav-link link-dark" id="'+id+'" onClick="'+action+'">'+title+'</a></li>');
}

function makeSideBar(sidebarItems){
    destroySidebar();
    $('#wrapper').prepend('<div id="sidebar"></div>');
    $('#sidebar').append('<ul class="nav nav-pills flex-column mb-auto"></ul>');   

    for (let i = 0; i < sidebarItems.length; i++) {
        addSidebarItem(sidebarItems[i][0],sidebarItems[i][1],sidebarItems[i][2]);
    }
}

/*
 * END SIDEBAR CODE
 */

function pageLoad(){
    // Make a call to wake up the API and find out if AD is enabled or not
    let request_json = "{\"type\":\"ADcheck\"}";
    $.post('api',
        request_json,
        function(data, status, xhr) {
            if(data=="true"){
                adStatus=true;
            }
            else{
                adStatus=false;
            }
        }
    )
    .fail(function(jqxhr, settings, ex) { alert('failed, ' + ex); });
    
    makeHeader();
}
