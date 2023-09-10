function onload()
    print(self)
    --self = nil
    if not self then
        print("[WARN]: nil object")
        return
    end
    data = self.getMaterialsInChildren()
    raw = nil
    for i,v in ipairs(data) do
        print(v)
        if i == 1 then raw = v end
    end
    if raw ~= nil then
        local keyword = "_DebugPhase"
        local value = 16.0
        raw.set(keyword, value)
        local n = raw.get(keyword)
        print("[INFO]: " .. keyword .. ": " .. tostring(n))
    end
end