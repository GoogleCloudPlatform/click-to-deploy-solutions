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

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.Date;

@WebServlet(urlPatterns = "/landing")
public class Landing extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Date date = new Date();
        long nocache = date.getTime() / 1000L;
        resp.setHeader("Expires", "Tue, 03 Jul 2001 06:00:00 GMT");
        resp.setDateHeader("Last-Modified", new Date().getTime());
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0, post-check=0, pre-check=0");
        resp.setHeader("Pragma", "no-cache");
        PrintWriter out = resp.getWriter();
        out.println("<html>");
        out.println("<head>");
        out.println("<title>reCAPTCHA Enterprise Demo</title>");
        out.println("<script src=\"js/vars.js?nocache="+nocache+"\"></script>");
        out.println("<script id=\"recap\" src=\"https://www.google.com/recaptcha/enterprise.js?render="+System.getenv("V3KEY")+"&onload=pageLoad\"></script>");
        
        out.println("<link href=\"css/main.css\" rel=\"stylesheet\">");
        out.println("<link href=\"css/loaders.css?nocache="+nocache+"\" rel=\"stylesheet\">");
        out.println("<script src=\"third_party/jquery.min.js\"></script>");
        out.println("<link href=\"third_party/bootstrap.min.css\" rel=\"stylesheet\">");
        out.println("<script src=\"third_party/bootstrap.bundle.min.js\"></script>");
        out.println("<link rel=\"icon\" type=\"image/x-icon\" href=\"/favicon.ico\">");
        out.println("<script>\n let commitId = \""+System.getenv("COMMITID")+"\";\n</script>");
        out.println("</head>");
        out.println("<body><div class='wrapper' id='wrapper'></div>");
        out.println("<script src=\"js/app.js?nocache="+nocache+"\"></script>");
        out.println("<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>");
        out.println("<div style=\"background-color:white;width:500px;max-width:500px;display:inline-block;float:left;\" class=\"fixed-bottom\">");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    }
}
