package com.demo;
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
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Base64;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.cloud.recaptcha.passwordcheck.PasswordCheckResult;
import com.google.cloud.recaptcha.passwordcheck.PasswordCheckVerification;
import com.google.cloud.recaptcha.passwordcheck.PasswordCheckVerifier;

import com.google.cloud.recaptchaenterprise.v1.RecaptchaEnterpriseServiceClient;
import com.google.protobuf.ByteString;
import com.google.recaptchaenterprise.v1.Assessment;
import com.google.recaptchaenterprise.v1.CreateAssessmentRequest;
import com.google.recaptchaenterprise.v1.Event;
import com.google.recaptchaenterprise.v1.ListRelatedAccountGroupsRequest;
import com.google.recaptchaenterprise.v1.ProjectName;

import java.util.List;

import com.google.recaptchaenterprise.v1.PrivatePasswordLeakVerification;
import com.google.cloud.recaptchaenterprise.v1.RecaptchaEnterpriseServiceSettings;
import com.google.api.gax.core.NoCredentialsProvider;
import com.google.api.gax.rpc.FixedHeaderProvider;

import com.google.recaptchaenterprise.v1.AnnotateAssessmentRequest;
import com.google.recaptchaenterprise.v1.AnnotateAssessmentRequest.Reason;
import com.google.recaptchaenterprise.v1.AssessmentName;
import com.google.recaptchaenterprise.v1.AnnotateAssessmentRequest.Annotation;

/**
 * API Servlet
 */
@WebServlet(urlPatterns = "/api")
public class Api extends HttpServlet {
    private String apiKey = System.getenv("APIKEY");
    private String v3key = System.getenv("V3KEY");
    private String v2key = System.getenv("V2KEY");
    private String test2key = System.getenv("TEST2KEY");
    private String test8key = System.getenv("TEST8KEY");
    private String projectId = System.getenv("PROJECTID"); 
    private String expressKey = System.getenv("EXPRESSKEY"); 

    // Quickest way to check Account Defender is enabled is to perform a request that is not featured in the demo.
    // This feature is to find related account groups, which is an advanced feature. For more info see the docs at
    // https://cloud.google.com/recaptcha/docs/account-query-apis. If this fails it's because AD is not enabled.
    public boolean isAdEnabled(String projectId) throws IOException {
        try {
            RecaptchaEnterpriseServiceClient client = RecaptchaEnterpriseServiceClient.create(settings());
            ListRelatedAccountGroupsRequest request =
                ListRelatedAccountGroupsRequest.newBuilder().setParent(ProjectName.of(projectId).toString()).build();
            // this next command fails if AD is switched off and is why this block has to be inside a try catch
            client.listRelatedAccountGroups(request).iterateAll(); 
            return true;
        }
        catch(Exception e){
            return false;
        }
    }

    private RecaptchaEnterpriseServiceSettings settings(){
        RecaptchaEnterpriseServiceSettings config;
        try{
            config = RecaptchaEnterpriseServiceSettings.newBuilder()
            .setCredentialsProvider(NoCredentialsProvider.create())
            .setHeaderProvider(
                FixedHeaderProvider.create(
                    "X-goog-api-key", apiKey, 
                    "User-Agent", "Heroes reCAPTCHA Enterprise Example v0.0.1"))
            .build();
        }
        catch(Exception e){
            config = null;
        }
        return config;            
    }          

    private PLDReply checkHashes(String username, String password, String action, String token, String hashedAccountId, String siteKey) throws InterruptedException, IOException, Exception{
        Reply reply = new Reply();
        PLDReply pldReply = new PLDReply();
        try (RecaptchaEnterpriseServiceClient client = RecaptchaEnterpriseServiceClient.create(settings())) {
            PasswordCheckVerifier passwordLeak = new PasswordCheckVerifier();
            PasswordCheckVerification verification = passwordLeak.createVerification(username,password).get();
            PrivatePasswordLeakVerification pldVerification =
            PrivatePasswordLeakVerification.newBuilder()
                    .setLookupHashPrefix(ByteString.copyFrom(verification.getLookupHashPrefix()))
                    .setEncryptedUserCredentialsHash(ByteString.copyFrom(verification.getEncryptedUserCredentialsHash()))
                    .build();
            reply.setData(pldVerification.toString());
            Assessment requestAssessment =
            Assessment.newBuilder().setPrivatePasswordLeakVerification(pldVerification).build();
            Assessment response = client.createAssessment("projects/"+ projectId,requestAssessment);
            PrivatePasswordLeakVerification credentials = response.getPrivatePasswordLeakVerification();
            List<byte[]> leakMatchPrefixes =
            credentials.getEncryptedLeakMatchPrefixesList().stream()
                .map(ByteString::toByteArray)
                .collect(Collectors.toList());

            PasswordCheckResult result =
                passwordLeak
                    .verify(
                        verification,
                        credentials.getReencryptedUserCredentialsHash().toByteArray(),
                        leakMatchPrefixes)
                    .get();
            reply.setResult(response.toString());
            pldReply.setReply(reply);
            pldReply.setPldResult(result.areCredentialsLeaked());
        }
        return pldReply;
    }

    private Reply annotate(String assessmentId, String annotation, String reason) throws Exception{
        Reply reply = new Reply();
        Annotation legitOrFraud = Annotation.LEGITIMATE;
        if(annotation.equals("FRAUDULENT")) legitOrFraud = Annotation.FRAUDULENT;
        Reason annotationReason = Reason.valueOf(reason);
        
        String base64httpReplyRaw = "HTTP/2 200 \\r<br>\n" + //
                                    "content-type: application/json; charset=UTF-8\\r<br>\n" + //
                                    "vary: X-Origin\\r<br>\n" + //
                                    "vary: Referer\\r<br>\n" + //
                                    "vary: Origin,Accept-Encoding\\r<br>\n" + //
                                    "server: scaffolding on HTTPServer2\\r<br>\n" + //
                                    "cache-control: private\\r<br>\n" + //
                                    "x-xss-protection: 0\\r<br>\n" + //
                                    "x-frame-options: SAMEORIGIN\\r<br>\n" + //
                                    "x-content-type-options: nosniff\\r<br>\n" + //
                                    "alt-svc: h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000\\r<br>\n" + //
                                    "accept-ranges: none\\r<br>\n" + //
                                    "\\r<br>\n" + //
                                    "{}<br>";
    
        try (RecaptchaEnterpriseServiceClient client = RecaptchaEnterpriseServiceClient.create(settings())) {
            AnnotateAssessmentRequest annotateAssessmentRequest =
                AnnotateAssessmentRequest.newBuilder()
                    .setName(AssessmentName.of(projectId, assessmentId).toString())
                    .setAnnotation(legitOrFraud).addReasons(annotationReason)
                    .build();
            if(annotationReason == Reason.REASON_UNSPECIFIED){
                annotateAssessmentRequest = AnnotateAssessmentRequest.newBuilder()
                .setName(AssessmentName.of(projectId, assessmentId).toString())
                .setAnnotation(legitOrFraud)
                .build();
            }
            client.annotateAssessment(annotateAssessmentRequest);
            reply.setData(annotateAssessmentRequest.toString());
            reply.setResult(base64httpReplyRaw);
        }
        catch(Exception e){
            System.out.println("annotate error: "+e);
        }
        return reply;
    }

    private Reply error(String msg){
        Reply reply = new Reply();
        reply.setData("error");
        reply.setResult(msg);
        return reply;
    }

    private Reply createAssessment(String projectID, Event event)
    throws Exception {
        Reply reply = new Reply();        
        try {
            try (RecaptchaEnterpriseServiceClient client = RecaptchaEnterpriseServiceClient.create(settings())) {
                reply.setData(event.toString());
                CreateAssessmentRequest createAssessmentRequest =
                    CreateAssessmentRequest.newBuilder()
                        .setParent(ProjectName.of(projectID).toString())
                        .setAssessment(Assessment.newBuilder().setEvent(event).build())
                        .build();
                Assessment response = client.createAssessment(createAssessmentRequest);                   
                reply.setResult(response.toString());
            }
        }
        catch(Exception e){   
            reply.setResult("Error with recaptchaclient: "+e);
        }   
        return reply;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PrintWriter gOut = resp.getWriter();
        gOut.println("<html><head><title>Rick Roll</title></head><body>Not implemented <a href='//go/bishopmov2' alt='Rick roll me'>redirect...</a></body></html>");
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException{
        PrintWriter out = resp.getWriter();

        StringBuffer jb = new StringBuffer();
        String line = null;
        try {
            BufferedReader reader = req.getReader();
            while ((line = reader.readLine()) != null)
            jb.append(line);
        } 
        catch (Exception e) { 
            throw new IOException("Error buffering JSON request string: "+e);
        }

        try {            
            JSONObject jsonObject = new JSONObject(jb.toString());  
            try{    
                if(jsonObject.has("type") && jsonObject.has("subtype") && jsonObject.has("token") && jsonObject.has("action")){                    
                    String type = jsonObject.getString("type");
                    String subType = jsonObject.getString("subtype");
                    String siteKey = v3key;
                    if(type.equals("recap")){
                        if(subType.equals("test2")){
                            siteKey=test2key;
                        }
                        else if(subType.equals("test8")){
                            siteKey=test8key;
                        }
                        else if(subType.equals("v2")){
                            siteKey=v2key;
                        }
                        try{
                            Event event = Event.newBuilder().setSiteKey(siteKey).setToken(jsonObject.getString("token")).setExpectedAction(jsonObject.getString("action")).build();
                            Reply reply = createAssessment(projectId,event);
                            // For a standard assessment, to make things cleaner in the demo, we want to remove the account defender enum.
                            // It might not be present depending on the project state, so we check first before removing it.
                            // The reply string will be base64 encoded, so you need to decode, do the test, then remove
                            String adReplyCheck = new String(Base64.getDecoder().decode(reply.getResult()),"UTF-8");
                            if(adReplyCheck.indexOf("account_defender_assessment")>-1){
                                reply.setResult(adReplyCheck.substring(0,adReplyCheck.indexOf("account_defender_assessment")));
                            }
                            out.println(reply.asJSON());
                        }
                        catch(Exception e){
                            throw new IOException("Error creating Reply object in normal assessment: "+e);
                        }
                                              
                    }
                    else if(type.equals("AD")){
                        try{
                            String hashedAccountId = jsonObject.getString("hashedAccountId");                                                          
                            try{         
                                Event.Builder eventBuilder =
                                    Event.newBuilder()
                                        .setSiteKey(siteKey)
                                        .setToken(jsonObject.getString("token"))
                                        .setExpectedAction(jsonObject.getString("action"));

                                if(!subType.equals("creation")){ 
                                    eventBuilder.setUserInfo(
                                        com.google.recaptchaenterprise.v1.UserInfo.newBuilder()
                                        .setAccountId(hashedAccountId)
                                        .addUserIds(com.google.recaptchaenterprise.v1.UserId.newBuilder().setUsername("username1"))
                                        .addUserIds(com.google.recaptchaenterprise.v1.UserId.newBuilder().setEmail("emailAddress@example.com"))
                                        .addUserIds(com.google.recaptchaenterprise.v1.UserId.newBuilder().setPhoneNumber("+447123789456")));
                                } 
                                Event event = eventBuilder.build();
                                Reply reply = createAssessment(projectId,event);

                                /*
                                 * For demonstation purposes, modify the response to show what the results look like for 
                                 * SUSPICIOUS_LOGIN_ACTIVITY and SUSPICIOUS_ACCOUNT_CREATION flags.
                                 */
                                String newLabel = new String();

                                if(subType.equals("unusual")){
                                    newLabel = "SUSPICIOUS_LOGIN_ACTIVITY";
                                }
                                if(subType.equals("creation")){
                                    newLabel = "SUSPICIOUS_ACCOUNT_CREATION";
                                }
                            
                                if(subType.equals("unusual")||subType.equals("creation")){
                                    String response = new String(Base64.getDecoder().decode(reply.getResult()),"UTF-8");                                    
                                    // Depending on whether an annotation was performed, there could be a PROFILE_MATCH.
                                    // If so we want to swap PROFILE match, if not we want to add a new label
                                    if(response.indexOf("PROFILE_MATCH")>-1){
                                        response = response.replace("PROFILE_MATCH", newLabel);
                                    }
                                    else{
                                        response = response.replace(
                                            "account_defender_assessment {", 
                                            "account_defender_assessment {\n  labels: "+newLabel
                                        );
                                    }
                                    reply.setResult(response);
                                }
                                out.println(reply.asJSON());
                            }
                            catch(Exception e){
                                throw new IOException("Error creating Reply object in AD event: "+e);
                            }
                            
                        }
                        catch(Exception e){
                            throw new IOException("Some error with making an AD object: "+e);
                        }                        
                    }
                    else if(type.equals("PLD")){
                        String username = jsonObject.getString("username");
                        String password = jsonObject.getString("password");
                        if(username.length()==0 || password.length()==0){
                            out.println(error("Username or password empty").asJSON());
                        }
                        else{
                            try{
                                PLDReply recaptchaResponse = checkHashes(username,password,"standalone",null,null,siteKey);
                                out.println(recaptchaResponse.asJSON());
                            }
                            catch(Exception e){
                                out.println(e);
                            }
                        }                        
                    }
                    else if(type.equals("express")){
                        String ipAddr = "8.8.8.8"; // Google DNS
                        String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"; // Chrome on Windows
                        String requestedUri = "https://auth.example.com/login";
                        if(subType.equals("bad")){
                            ipAddr = "171.25.193.25"; // Tor exit node
                            userAgent = "Mozilla/5.0 (X11; Kali Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36"; // Kali linux
                        }
                        try{
                            Event event = Event.newBuilder().setSiteKey(expressKey).setExpress(true).setUserIpAddress(ipAddr).setUserAgent(userAgent).setRequestedUri(requestedUri).build();
                            Reply reply = createAssessment(projectId,event);
                            // For a standard assessment, to make things cleaner in the demo, we want to remove the account defender enum.
                            // It might not be present depending on the project state, so we check first before removing it.
                            // The reply string will be base64 encoded, so you need to decode, do the test, then remove
                            String adReplyCheck = new String(Base64.getDecoder().decode(reply.getResult()),"UTF-8");
                            if(adReplyCheck.indexOf("account_defender_assessment")>-1){
                                reply.setResult(adReplyCheck.substring(0,adReplyCheck.indexOf("account_defender_assessment")));
                            }
                            out.println(reply.asJSON());
                        }
                        catch(Exception e){
                            throw new IOException("Error creating Reply object in normal assessment: "+e);
                        }
                    }

                    else{
                        out.println(error("Nothing implemented for type '"+type+"'!").asJSON());
                    }
                }
                else if(jsonObject.has("type") && jsonObject.getString("type").equals("annotation") && jsonObject.has("assessment_id")){
                    /* 
                      Annotation's don't have a JSON body in their response, so they are hard to demo. The
                      normal makeRecaptchaAssessmentCall() won't work, and if you actually make an annotation
                      nothing really comes back. So instead we'll return some fixed data that is visually a 
                      little more interesting    
                    */              
                    // This is {"annotation":"LEGITIMATE"}
                    String base64httpRequestBody = "eyJhbm5vdGF0aW9uIjoiTEVHSVRJTUFURSJ9"; 
                    // This is a dmummy HTTP header and empty {}
                    
                    Reply reply = annotate(jsonObject.getString("assessment_id"),jsonObject.getString("annotation"),jsonObject.getString("reason"));
                    out.println(reply.asJSON());                        
                }
                else if(jsonObject.has("type") && jsonObject.getString("type").equals("ADcheck")){
                    // This is to check if AD has been enabled
                    out.print(isAdEnabled(projectId));
                }
                else{
                    // if no token, action, type or subtype                    
                    if(!jsonObject.has("type")) out.println(error("Input not complete: no type").asJSON());
                    if(!jsonObject.has("subType")) out.println(error("Input not complete: no subType").asJSON());
                    if(!jsonObject.has("token")) out.println(error("Input not complete: no token").asJSON());
                    if(!jsonObject.has("action")) out.println(error("Input not complete: no action").asJSON());
                }
            }
            catch(Exception e){
                throw new IOException("Error parsing JSON string: "+e);
            }
            
        } catch (Exception e) {
            throw new IOException("Error creating JSON object from request input JSON: \n"+jb.toString()+"\n\nStack strace: \n\n"+e);
        }
    }
}
