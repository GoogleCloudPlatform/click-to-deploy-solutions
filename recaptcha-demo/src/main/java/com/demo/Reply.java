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

import java.util.Base64;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

public class Reply{
    private String data = Base64.getEncoder().encodeToString("Error. Default value unchanged.".getBytes());
    private String result = Base64.getEncoder().encodeToString("Error. Default value unchanged.".getBytes());;

    public void setData (String data){
        this.data = Base64.getEncoder().encodeToString(data.toString().getBytes());
    }

    public void setResult (String result) {
        this.result = Base64.getEncoder().encodeToString(result.toString().getBytes());
    }

    public String getData(){
        return data;
    }

    public String getResult(){
        return result;
    }

    public String asJSON() throws Exception{
        String json;
        try {
            ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
            json = ow.writeValueAsString(this);
        }
        finally{}
        return json;
    }
}
