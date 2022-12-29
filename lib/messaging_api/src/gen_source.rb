# gen_source | events の source を作成します
def GenSource(params)
    source = {
        "type" => "user",
        "userID" => params["id"]
    }
    return source
end