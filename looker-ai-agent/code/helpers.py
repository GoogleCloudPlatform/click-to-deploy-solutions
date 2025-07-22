import urllib.parse  

def generate_looker_url(json_data, looker_instance_url):
    query = json_data.get("generatedLookerQuery", {})
    if not query:
        return "Invalid JSON structure: 'generatedLookerQuery' key not found."

    # --- 1. Construct the Base Path ---
    model = query.get("model")
    explore = query.get("explore")
    if not model or not explore:
        return "JSON must contain 'model' and 'explore' keys."

    base_url = f"{looker_instance_url.rstrip('/')}/explore/{model}/{explore}"    
    params = {}

    
    if "fields" in query and query["fields"]:
        params["fields"] = ",".join(query["fields"])

    if "filters" in query:
        for f in query["filters"]:
            filter_field = f"f[{f['field']}]"
            params[filter_field] = f['value']
    
    if "limit" in query:
        params["limit"] = query["limit"]

    query_string = urllib.parse.urlencode(params)
    
    return f"{base_url}?{query_string}"